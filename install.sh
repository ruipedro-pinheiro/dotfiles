#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-install.log"
BACKUP_BASE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-install-backups"
BACKUP_ROOT="$BACKUP_BASE/$(date +%Y%m%d-%H%M%S)"
MAX_BACKUPS=1
MIN_FREE_MB=2048
TMP_ROOT="$(mktemp -d)"
STAGED_BIN="$TMP_ROOT/bin"
STAGED_GNOME="$TMP_ROOT/gnome"
GNOME_ASSETS_STAGED=0
trap 'rm -rf "$TMP_ROOT"' EXIT
mkdir -p "$STAGED_BIN" "$STAGED_GNOME"

mkdir -p "$(dirname "$LOG_FILE")"
: > "$LOG_FILE"
if command -v tee >/dev/null 2>&1; then
  exec > >(tee -a "$LOG_FILE") 2>&1
else
  exec >> "$LOG_FILE" 2>&1
fi

log_phase() {
  printf '\n==> %s\n' "$1"
}

usage() {
  printf 'Usage: %s [--repair-desktop]\n' "$0" >&2
}

require_commands() {
  local missing=0

  for command_name in "$@"; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
      printf 'Missing required command: %s\n' "$command_name" >&2
      missing=1
    fi
  done

  if [ "$missing" -ne 0 ]; then
    printf 'Install the missing prerequisites and re-run %s.\n' "$0" >&2
    exit 1
  fi
}

require_free_space() {
  local available_kb required_kb path

  require_commands df awk
  required_kb=$((MIN_FREE_MB * 1024))
  for path in "$HOME" "$TMP_ROOT"; do
    available_kb="$(df -Pk "$path" | awk 'NR == 2 { print $4 }')"
    if [ -z "$available_kb" ] || [ "$available_kb" -lt "$required_kb" ]; then
      printf 'At least %s MiB of free space is required in %s.\n' "$MIN_FREE_MB" "$path" >&2
      exit 1
    fi
  done
}

prune_backups() {
  local backups backup kept=0 index

  [ -d "$BACKUP_BASE" ] || return
  backups=("$BACKUP_BASE"/*)
  [ -e "${backups[0]}" ] || return
  for ((index=${#backups[@]} - 1; index >= 0; index--)); do
    backup="${backups[$index]}"
    if [ "$kept" -lt "$MAX_BACKUPS" ]; then
      kept=$((kept + 1))
    else
      rm -rf "$backup"
    fi
  done
}

backup_item() {
  local target="$1"
  local rel backup

  if [ ! -e "$target" ] && [ ! -L "$target" ]; then
    return
  fi
  rel="${target#"$HOME"/}"
  backup="$BACKUP_ROOT/$rel"
  mkdir -p "$(dirname "$backup")"
  mv "$target" "$backup"
}

link_item() {
  local source="$1"
  local target="$2"
  local rel backup

  mkdir -p "$(dirname "$target")"

  if [ -L "$target" ]; then
    if [ "$(readlink -f "$target")" = "$source" ]; then
      return
    fi
  fi

  if [ -e "$target" ] || [ -L "$target" ]; then
    rel="${target#"$HOME"/}"
    backup="$BACKUP_ROOT/$rel"
    mkdir -p "$(dirname "$backup")"
    mv "$target" "$backup"
  fi

  ln -sfn "$source" "$target"
}

prepare_nvim() {
  require_commands git
  git -C "$REPO_DIR" submodule update --init --recursive -- .config/nvim
  if [ ! -f "$REPO_DIR/.config/nvim/install.sh" ]; then
    printf 'Expected nvim submodule installer not found.\n' >&2
    exit 1
  fi
  link_item "$REPO_DIR/.config/nvim" "$HOME/.config/nvim"
  bash "$REPO_DIR/.config/nvim/install.sh"
}

cleanup_stale_local_tools() {
  local tool path resolved

  mkdir -p "$HOME/.local/bin"

  for tool in bat eza fastfetch gdb lazygit lazycommit lazycommit-edit starship zoxide; do
    path="$HOME/.local/bin/$tool"
    if [ ! -e "$path" ] && [ ! -L "$path" ]; then
      continue
    fi

    if [ -L "$path" ]; then
      resolved="$(readlink -f "$path" || true)"
      if [ "$tool" = "lazycommit-edit" ] && [ "$resolved" = "$REPO_DIR/bin/lazycommit-edit" ]; then
        continue
      fi
      rm -f "$path"
    elif [ -f "$path" ]; then
      rm -f "$path"
    else
      printf 'Skipping non-file local tool path: %s\n' "$path" >&2
    fi
  done
}

prepare_shell() {
  local custom="$HOME/.local/share/oh-my-zsh-custom"
  local autosuggestions="$custom/plugins/zsh-autosuggestions"
  local highlighting="$custom/plugins/zsh-syntax-highlighting"
  local staged_autosuggestions="$TMP_ROOT/zsh-autosuggestions"
  local staged_highlighting="$TMP_ROOT/zsh-syntax-highlighting"

  require_commands git
  git -C "$REPO_DIR" submodule update --init --recursive -- .oh-my-zsh
  git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions \
    "$staged_autosuggestions"
  git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting \
    "$staged_highlighting"
  link_item "$REPO_DIR/.oh-my-zsh" "$HOME/.oh-my-zsh"
  mkdir -p "$custom/plugins"
  backup_item "$autosuggestions"
  backup_item "$highlighting"
  mv "$staged_autosuggestions" "$autosuggestions"
  mv "$staged_highlighting" "$highlighting"
}

release_asset_metadata() {
  local repo="$1"
  local asset_regex="$2"

  curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
    | python3 -c '
import json, re, sys
pattern = re.compile(sys.argv[1])
release = json.load(sys.stdin)
for asset in release.get("assets", []):
    if pattern.fullmatch(asset.get("name", "")):
        digest = asset.get("digest", "")
        if not digest.startswith("sha256:"):
            raise SystemExit("release asset has no SHA-256 digest")
        print(asset["browser_download_url"] + "\t" + digest)
        raise SystemExit(0)
raise SystemExit("no release asset matched " + sys.argv[1])
' "$asset_regex"
}

install_release_binary() {
  local repo="$1"
  local asset_regex="$2"
  local binary_name="$3"
  local metadata url digest checksum asset_name tmp archive

  require_commands curl python3 sha256sum install

  metadata="$(release_asset_metadata "$repo" "$asset_regex")"
  url="${metadata%%$'\t'*}"
  digest="${metadata#*$'\t'}"
  checksum="${digest#sha256:}"
  asset_name="${url##*/}"
  tmp="$(mktemp -d "$TMP_ROOT/release.XXXXXX")"
  archive="$tmp/$asset_name"

  curl -fsSL "$url" -o "$archive"
  printf '%s  %s\n' "$checksum" "$archive" | sha256sum -c -

  python3 "$REPO_DIR/scripts/extract-release-binary.py" \
    "$archive" "$binary_name" "$STAGED_BIN/$binary_name"
  rm -rf "$tmp"
}

install_latest_lazygit() {
  install_release_binary 'jesseduffield/lazygit' 'lazygit_[^/]+_linux_x86_64\.tar\.gz' 'lazygit'
}

install_latest_lazycommit() {
  install_release_binary 'm7medVision/lazycommit' 'lazycommit_[^/]+_linux_amd64\.tar\.gz' 'lazycommit'
}

install_latest_zoxide() {
  install_release_binary 'ajeetdsouza/zoxide' 'zoxide-[^/]+-x86_64-unknown-linux-musl\.tar\.gz' 'zoxide'
}

install_latest_gdb() {
  install_release_binary 'guyush1/gdb-static' 'gdb-static-full-x86_64\.tar\.gz' 'gdb'
}

install_latest_bat() {
  install_release_binary 'sharkdp/bat' 'bat-v[^/]+-x86_64-unknown-linux-musl\.tar\.gz' 'bat'
}

install_latest_eza() {
  install_release_binary 'eza-community/eza' 'eza_x86_64-unknown-linux-musl\.tar\.gz' 'eza'
}

install_latest_fastfetch() {
  install_release_binary 'fastfetch-cli/fastfetch' 'fastfetch-musl-amd64\.tar\.gz' 'fastfetch'
}

install_latest_starship() {
  install_release_binary 'starship/starship' 'starship-x86_64-unknown-linux-musl\.tar\.gz' 'starship'
}

gnome_session_present() {
  case ":${XDG_CURRENT_DESKTOP:-}:${DESKTOP_SESSION:-}:${GNOME_DESKTOP_SESSION_ID:-}:" in
    *GNOME*|*gnome*) return 0 ;;
    *) return 1 ;;
  esac
}

gnome_shell_major() {
  gnome-shell --version | python3 -c '
import re, sys
match = re.search(r"\b([0-9]+)\b", sys.stdin.read())
if not match:
    raise SystemExit("could not detect GNOME Shell major version")
print(match.group(1))
'
}

preflight_gnome_session_write() {
  local current_theme writable

  writable="$(gsettings writable org.gnome.desktop.interface gtk-theme)"
  if [ "$writable" != 'true' ]; then
    printf 'GNOME settings are not writable in the current session.\n' >&2
    return 1
  fi
  current_theme="$(gsettings get org.gnome.desktop.interface gtk-theme)"
  if ! gsettings set org.gnome.desktop.interface gtk-theme "$current_theme"; then
    printf 'GNOME settings write probe failed; run repair from the logged-in user session.\n' >&2
    return 1
  fi
}

stage_bibata_cursor() {
  local url checksum archive staged_cursor

  require_commands curl python3 sha256sum
  url='https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7/Bibata-Modern-Ice.tar.xz'
  checksum='a68cae60c4dc706350e194ebc91c5fe48bc7bc9d59e119555834a2a7ee5078ef'
  archive="$STAGED_GNOME/Bibata-Modern-Ice.tar.xz"
  staged_cursor="$STAGED_GNOME/Bibata-Modern-Ice"

  curl -fsSL "$url" -o "$archive"
  printf '%s  %s\n' "$checksum" "$archive" | sha256sum -c -
  python3 "$REPO_DIR/scripts/extract-cursor-theme.py" \
    "$archive" 'Bibata-Modern-Ice' "$staged_cursor"
}

stage_gnome_extension() {
  local extension_id="$1"
  local uuid="$2"
  local shell_major="$3"
  local metadata download_url zip

  metadata="$(curl -fsSL "https://extensions.gnome.org/extension-info/?pk=$extension_id&shell_version=$shell_major")"
  download_url="$(printf '%s' "$metadata" | python3 "$REPO_DIR/scripts/gnome-extension-resolver.py" "$uuid")"
  zip="$STAGED_GNOME/$uuid.zip"
  curl -fsSL "$download_url" -o "$zip"
}

stage_gnome_extensions() {
  local shell_major

  require_commands curl gnome-shell python3
  shell_major="$(gnome_shell_major)"
  stage_gnome_extension 3193 'blur-my-shell@aunetx' "$shell_major"
  stage_gnome_extension 307 'dash-to-dock@micxgx.gmail.com' "$shell_major"
  stage_gnome_extension 19 'user-theme@gnome-shell-extensions.gcampax.github.com' "$shell_major"
  stage_gnome_extension 3843 'just-perfection-desktop@just-perfection' "$shell_major"
  stage_gnome_extension 517 'caffeine@patapon.info' "$shell_major"
  stage_gnome_extension 779 'clipboard-indicator@tudmotu.com' "$shell_major"
  stage_gnome_extension 615 'appindicatorsupport@rgcjonas.gmail.com' "$shell_major"
  stage_gnome_extension 8 'places-menu@gnome-shell-extensions.gcampax.github.com' "$shell_major"
  stage_gnome_extension 6 'apps-menu@gnome-shell-extensions.gcampax.github.com' "$shell_major"
}

stage_gnome_assets() {
  local mode="${1:-optional}"

  if [ "$mode" != 'required' ] && ! gnome_session_present; then
    printf 'GNOME automation skipped: no GNOME session detected.\n' >&2
    GNOME_ASSETS_STAGED=0
    return
  fi
  if [ "$mode" = 'required' ]; then
    require_commands curl dconf gnome-extensions gnome-shell gsettings python3 sha256sum
  elif ! command -v gnome-shell >/dev/null 2>&1 || ! command -v gnome-extensions >/dev/null 2>&1 || ! command -v dconf >/dev/null 2>&1 || ! command -v gsettings >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1 || ! command -v python3 >/dev/null 2>&1 || ! command -v sha256sum >/dev/null 2>&1; then
    printf 'GNOME automation skipped: required GNOME commands are unavailable.\n' >&2
    GNOME_ASSETS_STAGED=0
    return
  fi
  preflight_gnome_session_write

  log_phase 'Staging GNOME desktop assets'
  stage_bibata_cursor
  stage_gnome_extensions
  GNOME_ASSETS_STAGED=1
}

activate_gnome_extension() {
  local uuid="$1"
  local zip="$STAGED_GNOME/$uuid.zip"

  gnome-extensions install --force "$zip"
  if ! gnome-extensions enable "$uuid"; then
    printf 'GNOME extension enable deferred until session restart: %s\n' "$uuid" >&2
  fi
}

activate_gnome_customization() {
  [ "$GNOME_ASSETS_STAGED" -eq 1 ] || return

  log_phase 'Activating GNOME desktop assets'
  mkdir -p "$HOME/.local/share/icons" "$HOME/.local/share/themes"
  backup_item "$HOME/.local/share/icons/Bibata-Modern-Ice"
  mv "$STAGED_GNOME/Bibata-Modern-Ice" "$HOME/.local/share/icons/Bibata-Modern-Ice"

  activate_gnome_extension 'blur-my-shell@aunetx'
  activate_gnome_extension 'dash-to-dock@micxgx.gmail.com'
  activate_gnome_extension 'user-theme@gnome-shell-extensions.gcampax.github.com'
  activate_gnome_extension 'just-perfection-desktop@just-perfection'
  activate_gnome_extension 'caffeine@patapon.info'
  activate_gnome_extension 'clipboard-indicator@tudmotu.com'
  activate_gnome_extension 'appindicatorsupport@rgcjonas.gmail.com'
  activate_gnome_extension 'places-menu@gnome-shell-extensions.gcampax.github.com'
  activate_gnome_extension 'apps-menu@gnome-shell-extensions.gcampax.github.com'
  "$REPO_DIR/.config/gnome/apply-gnome.sh"
}

install_gnome_customization() {
  activate_gnome_customization
}

stage_tool_releases() {
  log_phase 'Staging verified CLI tool releases'
  install_latest_lazygit
  install_latest_lazycommit
  install_latest_zoxide
  install_latest_gdb
  install_latest_bat
  install_latest_eza
  install_latest_fastfetch
  install_latest_starship
}

stage_all_assets() {
  stage_tool_releases
  stage_gnome_assets
}

activate_tools() {
  local tool

  log_phase 'Activating CLI tools'
  mkdir -p "$HOME/.local/bin"
  cleanup_stale_local_tools
  for tool in bat eza fastfetch gdb lazygit lazycommit starship zoxide; do
    install -m 0755 "$STAGED_BIN/$tool" "$HOME/.local/bin/$tool"
  done
  link_item "$REPO_DIR/bin/lazycommit-edit" "$HOME/.local/bin/lazycommit-edit"
}

link_core_dotfiles() {
  log_phase 'Linking core dotfiles'
  link_item "$REPO_DIR/.bashrc" "$HOME/.bashrc"
  link_item "$REPO_DIR/.zshrc" "$HOME/.zshrc"
  link_item "$REPO_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
  link_item "$REPO_DIR/.config/background" "$HOME/.config/background"
  link_item "$REPO_DIR/.config/gnome" "$HOME/.config/gnome"
  link_item "$REPO_DIR/.config/kitty" "$HOME/.config/kitty"
  link_item "$REPO_DIR/.config/fastfetch" "$HOME/.config/fastfetch"
  link_item "$REPO_DIR/.config/lazygit" "$HOME/.config/lazygit"
  link_item "$REPO_DIR/.config/zed" "$HOME/.config/zed"
  link_item "$REPO_DIR/.config/btop" "$HOME/.config/btop"
  link_item "$REPO_DIR/.local/share/fonts/Monaspace" "$HOME/.local/share/fonts/Monaspace"
  link_item "$REPO_DIR/.local/share/icons/Hatter-FluentFiles" "$HOME/.local/share/icons/Hatter-FluentFiles"
  link_item "$REPO_DIR/.themes/Catppuccin-Mauve-Dark" "$HOME/.local/share/themes/Catppuccin-Mauve-Dark"
}

refresh_fonts() {
  if command -v fc-cache >/dev/null 2>&1; then
    log_phase 'Refreshing font cache'
    fc-cache -f "$HOME/.local/share/fonts" >/dev/null
  fi
}

full_install() {
  require_free_space
  stage_all_assets
  prune_backups
  log_phase 'Preparing Neovim'
  prepare_nvim
  log_phase 'Preparing shell plugins'
  prepare_shell
  link_core_dotfiles
  activate_tools
  install_gnome_customization
  prune_backups
  refresh_fonts
}

repair_desktop() {
  require_free_space
  stage_gnome_assets required
  prune_backups
  link_core_dotfiles
  activate_gnome_customization
  prune_backups
  refresh_fonts
}

case "${1:-}" in
  '')
    full_install
    ;;
  --repair-desktop)
    [ "$#" -eq 1 ] || { usage; exit 2; }
    repair_desktop
    ;;
  *)
    printf 'Unknown argument: %s\n' "$1" >&2
    usage
    exit 2
    ;;
esac

printf 'Dotfiles linked from %s\n' "$REPO_DIR"
printf 'Backups stored in %s\n' "$BACKUP_ROOT"
printf 'Install log stored in %s\n' "$LOG_FILE"
