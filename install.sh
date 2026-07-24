#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_BASE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-install-backups"
BACKUP_ROOT="$BACKUP_BASE/$(date +%Y%m%d-%H%M%S)"
MAX_BACKUPS=1
MIN_FREE_MB=2048
TMP_ROOT="$(mktemp -d)"
STAGED_BIN="$TMP_ROOT/bin"
trap 'rm -rf "$TMP_ROOT"' EXIT
mkdir -p "$STAGED_BIN"

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
  mkdir -p "$HOME/.local/bin"

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

activate_tools() {
  local tool

  cleanup_stale_local_tools
  for tool in bat eza fastfetch gdb lazygit lazycommit starship zoxide; do
    install -m 0755 "$STAGED_BIN/$tool" "$HOME/.local/bin/$tool"
  done
  link_item "$REPO_DIR/bin/lazycommit-edit" "$HOME/.local/bin/lazycommit-edit"
}

require_free_space
install_latest_lazygit
install_latest_lazycommit
install_latest_zoxide
install_latest_gdb
install_latest_bat
install_latest_eza
install_latest_fastfetch
install_latest_starship
prune_backups
prepare_nvim
prepare_shell

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
activate_tools
prune_backups

if command -v fc-cache >/dev/null 2>&1; then
  fc-cache -f "$HOME/.local/share/fonts" >/dev/null
fi

printf 'Dotfiles linked from %s\n' "$REPO_DIR"
printf 'Backups stored in %s\n' "$BACKUP_ROOT"
