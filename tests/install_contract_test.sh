#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
install_sh="$repo_dir/install.sh"
apply_gnome_sh="$repo_dir/.config/gnome/apply-gnome.sh"
zshrc="$repo_dir/.zshrc"
gitmodules="$repo_dir/.gitmodules"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_contains() {
  local file="$1" pattern="$2" message="$3"
  grep -Eq -- "$pattern" "$file" || fail "$message"
}

assert_not_contains() {
  local file="$1" pattern="$2" message="$3"
  if grep -Eq -- "$pattern" "$file"; then
    fail "$message"
  fi
}

bash -n "$install_sh"
bash -n "$apply_gnome_sh"
zsh -n "$zshrc"

assert_contains "$gitmodules" 'path = \.config/nvim' 'nvim must be a git submodule'
assert_contains "$gitmodules" 'url = https://github\.com/ruipedro-pinheiro/nvim\.git' 'nvim submodule must use the canonical repo'
assert_contains "$install_sh" 'submodule update --init --recursive' 'install.sh must initialize the nvim submodule'
assert_contains "$install_sh" 'link_item "\$REPO_DIR/\.config/nvim"' 'install.sh must link the nvim submodule'
assert_not_contains "$install_sh" 'git clone .*ruipedro-pinheiro/nvim' 'install.sh must not create a second nvim clone'
assert_contains "$install_sh" 'install_latest_lazygit\(\)' 'install.sh must install latest lazygit'
assert_contains "$install_sh" 'install_latest_lazycommit\(\)' 'install.sh must install latest lazycommit'
assert_contains "$install_sh" 'install_latest_zoxide\(\)' 'install.sh must install latest zoxide'
assert_contains "$install_sh" 'install_latest_gdb\(\)' 'install.sh must install latest GDB'
assert_contains "$install_sh" 'install_latest_bat\(\)' 'install.sh must install latest bat'
assert_contains "$install_sh" 'install_latest_eza\(\)' 'install.sh must install latest eza'
assert_contains "$install_sh" 'install_latest_fastfetch\(\)' 'install.sh must install latest fastfetch'
assert_contains "$install_sh" 'install_latest_starship\(\)' 'install.sh must install latest starship'
assert_contains "$install_sh" 'cleanup_stale_local_tools\(\)' 'install.sh must clean stale local tool copies'
assert_contains "$install_sh" 'api\.github\.com/repos/\$repo/releases/latest' 'tool install must use the latest GitHub release API'
assert_contains "$install_sh" 'jesseduffield/lazygit' 'lazygit source repo missing'
assert_contains "$install_sh" 'm7medVision/lazycommit' 'lazycommit source repo missing'
assert_contains "$install_sh" 'ajeetdsouza/zoxide' 'zoxide source repo missing'
assert_contains "$install_sh" 'guyush1/gdb-static' 'portable GDB source repo missing'
assert_contains "$install_sh" 'sharkdp/bat' 'bat source repo missing'
assert_contains "$install_sh" 'eza-community/eza' 'eza source repo missing'
assert_contains "$install_sh" 'fastfetch-cli/fastfetch' 'fastfetch source repo missing'
assert_contains "$install_sh" 'starship/starship' 'starship source repo missing'
assert_contains "$install_sh" 'asset\.get\("digest"' 'release asset digest must come from the GitHub API'
assert_not_contains "$install_sh" 'continuing without checksum' 'release binaries must never bypass checksum verification'

for path in \
  '.config/lazygit' \
  '.config/zed' \
  '.config/btop'; do
  assert_contains "$install_sh" "link_item \"\\\$REPO_DIR/$path" "install.sh must link $path"
done
assert_not_contains "$install_sh" 'ghostty' 'Ghostty must not be managed by this repo'

assert_contains "$install_sh" 'for tool in bat eza fastfetch gdb lazygit lazycommit lazycommit-edit starship zoxide' 'stale local tool cleanup list is incomplete'
assert_contains "$install_sh" 'link_item "\$REPO_DIR/\.oh-my-zsh"' 'Oh My Zsh submodule must be linked'
assert_contains "$install_sh" 'link_item "\$REPO_DIR/\.zshrc" "\$HOME/\.zshrc"' 'system Zsh configuration must be linked'
assert_contains "$install_sh" 'link_item "\$REPO_DIR/\.config/kitty" "\$HOME/\.config/kitty"' 'system Kitty configuration must be linked'
assert_not_contains "$install_sh" 'zsh-bin|kovidgoyal/kitty|kitty-[^ ]*x86_64' 'installer must not download system-provided Zsh or Kitty binaries'
assert_contains "$install_sh" 'zsh-users/zsh-autosuggestions' 'zsh-autosuggestions install missing'
assert_contains "$install_sh" 'zsh-users/zsh-syntax-highlighting' 'zsh-syntax-highlighting install missing'
assert_contains "$install_sh" '\$TMP_ROOT/zsh-autosuggestions' 'zsh plugins must be staged before replacement'
assert_contains "$install_sh" 'backup_item' 'existing shell plugins must be backed up before replacement'
assert_not_contains "$install_sh" 'flashfetch' 'flashfetch must not be installed'
assert_contains "$install_sh" 'TMP_ROOT=' 'installer must use one disposable temp root'
assert_contains "$install_sh" "trap 'rm -rf \"\\\$TMP_ROOT\"' EXIT" 'temporary downloads must be removed on every exit'
assert_contains "$install_sh" 'prune_backups\(\)' 'old dotfiles backups must be pruned'
assert_contains "$install_sh" 'MAX_BACKUPS=1' 'only one dotfiles backup may be retained'
assert_contains "$install_sh" 'MIN_FREE_MB=2048' 'installer must reserve 2 GiB of free space'
assert_contains "$install_sh" 'require_free_space' 'free-space preflight missing'
assert_contains "$install_sh" 'for path in "\$HOME" "\$TMP_ROOT"' 'temporary filesystem space must be checked'
assert_contains "$install_sh" 'fastfetch-musl-amd64' 'fastfetch must use the self-contained musl build'
assert_contains "$install_sh" 'extract-release-binary\.py' 'safe release extractor must be used'
assert_not_contains "$install_sh" 'tar -x' 'release archives must not be extracted as directory trees'
assert_contains "$install_sh" 'link_item "\$REPO_DIR/\.themes/Catppuccin-Mauve-Dark" "\$HOME/\.local/share/themes/Catppuccin-Mauve-Dark"' 'Catppuccin GTK theme must be linked automatically'
assert_contains "$install_sh" 'Bibata-Modern-Ice\.tar\.xz' 'Bibata cursor archive name missing'
assert_contains "$install_sh" 'a68cae60c4dc706350e194ebc91c5fe48bc7bc9d59e119555834a2a7ee5078ef' 'Bibata cursor checksum missing'
assert_contains "$install_sh" 'extract-cursor-theme\.py' 'Bibata cursor archive must use the safe cursor extractor'
assert_contains "$install_sh" 'assets/gnome-42/SHA256SUMS' 'GNOME 42 assets must be verified from the repository'
assert_contains "$install_sh" 'assets/gnome-42/extensions' 'GNOME 42 extensions must install directly from the repository'
assert_contains "$install_sh" 'gnome-extension-resolver\.py' 'GNOME extension download URLs must be resolver-validated'
assert_contains "$install_sh" 'GNOME extension download skipped:' 'an unavailable extension must not abort the entire install'
assert_contains "$install_sh" 'GNOME extension install skipped:' 'a failed extension install must not abort desktop activation'
assert_contains "$install_sh" 'extension-info/\?pk=\$extension_id&shell_version=\$shell_major' 'GNOME extensions must resolve against detected Shell major version'
assert_contains "$install_sh" 'blur-my-shell@aunetx' 'Blur my Shell extension UUID missing'
assert_contains "$install_sh" 'dash-to-dock@micxgx\.gmail\.com' 'Dash to Dock extension UUID missing'
assert_contains "$install_sh" 'user-theme@gnome-shell-extensions\.gcampax\.github\.com' 'User Themes extension UUID missing'
assert_contains "$install_sh" 'just-perfection-desktop@just-perfection' 'Just Perfection extension UUID missing'
assert_contains "$install_sh" 'caffeine@patapon\.info' 'Caffeine extension UUID missing'
assert_contains "$install_sh" 'clipboard-indicator@tudmotu\.com' 'Clipboard Indicator extension UUID missing'
assert_contains "$install_sh" 'appindicatorsupport@rgcjonas\.gmail\.com' 'AppIndicator extension UUID missing'
assert_contains "$install_sh" 'places-menu@gnome-shell-extensions\.gcampax\.github\.com' 'Places Menu extension UUID missing'
assert_contains "$install_sh" 'apps-menu@gnome-shell-extensions\.gcampax\.github\.com' 'Applications Menu extension UUID missing'
assert_contains "$install_sh" 'GNOME automation skipped:' 'non-GNOME installs must skip with one concise warning'
assert_contains "$install_sh" 'command -v dconf' 'GNOME staging preflight must require dconf before HOME mutation'
assert_contains "$install_sh" 'command -v gsettings' 'GNOME staging preflight must require gsettings before HOME mutation'
assert_contains "$install_sh" 'preflight_gnome_session_write\(\)' 'GNOME staging must verify the settings session before HOME mutation'
assert_contains "$install_sh" 'gsettings writable org\.gnome\.desktop\.interface gtk-theme' 'GNOME session preflight must verify a writable setting'
assert_contains "$install_sh" 'gsettings set org\.gnome\.desktop\.interface gtk-theme' 'GNOME session preflight must prove writes using the unchanged value'
assert_contains "$install_sh" '\.config/gnome/apply-gnome\.sh' 'installer must apply GNOME settings after GNOME assets'
assert_not_contains "$install_sh" 'sudo' 'installer must remain no-sudo'
assert_contains "$apply_gnome_sh" 'desktop-background\.dconf' 'wallpaper dconf must be applied only by the opt-in branch'
assert_contains "$apply_gnome_sh" 'APPLY_WALLPAPER:-1' 'wallpaper changes must be on by default'
assert_contains "$apply_gnome_sh" 'APPLY_WALLPAPER:-1\}" != "0"' 'wallpaper changes must allow APPLY_WALLPAPER=0 opt-out'
assert_contains "$apply_gnome_sh" 'preflight' 'apply-gnome must preflight before dconf mutation'
assert_contains "$apply_gnome_sh" 'dotfiles-gnome-dconf\.snapshot' 'apply-gnome must keep one bounded dconf safety snapshot'
assert_contains "$apply_gnome_sh" 'trap .*rollback_dconf.*ERR' 'apply-gnome must rollback dconf on partial failure'
assert_contains "$install_sh" 'dotfiles-install\.log' 'installer must keep a persistent per-run log'
assert_contains "$install_sh" '--repair-desktop' 'installer must provide desktop repair mode'
assert_contains "$install_sh" 'stage_gnome_assets required' 'desktop repair must run outside an active GNOME session'
assert_contains "$install_sh" 'stage_all_assets' 'installer must stage assets before HOME mutation'
assert_contains "$install_sh" 'link_core_dotfiles' 'repair mode must relink core dotfiles including zshrc'
assert_contains "$install_sh" 'Unknown argument' 'installer must reject unknown arguments'

last_download_line="$(grep -n '^  stage_all_assets$' "$install_sh" | cut -d: -f1)"
activate_line="$(grep -n '^  activate_tools$' "$install_sh" | cut -d: -f1)"
shell_line="$(grep -n '^  prepare_shell$' "$install_sh" | cut -d: -f1)"
[ -n "$last_download_line" ] && [ -n "$activate_line" ] || fail 'tool staging order markers missing'
[ "$last_download_line" -lt "$activate_line" ] || fail 'old tools must remain until every replacement is staged'
[ -n "$shell_line" ] && [ "$last_download_line" -lt "$shell_line" ] || fail 'release failures must occur before shell configuration changes'

stage_gnome_line="$(grep -n '^stage_gnome_assets()' "$install_sh" | cut -d: -f1)"
link_core_line="$(grep -n '^link_core_dotfiles()' "$install_sh" | cut -d: -f1)"
[ -n "$stage_gnome_line" ] && [ -n "$link_core_line" ] || fail 'GNOME stage/link order markers missing'
[ "$stage_gnome_line" -lt "$link_core_line" ] || fail 'GNOME assets must be staged before HOME links or dconf changes'

assert_not_contains "$zshrc" 'claude|opencode|betternorm|spicetify' '.zshrc must not publish personal tool configuration'
assert_not_contains "$zshrc" 'alias rmdir=' '.zshrc must not replace the standard rmdir command'
assert_not_contains "$zshrc" 'MAX_THINKING_TOKENS|CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING|CLAUDE_CODE_EFFORT_LEVEL' '.zshrc must remove old Claude thinking env'
assert_not_contains "$zshrc" '~/bin/' '.zshrc must not require a visible ~/bin directory'
assert_contains "$zshrc" '\[ -r "\$ZSH/oh-my-zsh\.sh" \]' '.zshrc must tolerate missing Oh My Zsh during desktop repair'
assert_contains "$zshrc" 'command -v zoxide' '.zshrc must guard optional zoxide initialization'
assert_contains "$zshrc" 'command -v starship' '.zshrc must guard optional Starship initialization'
assert_contains "$zshrc" 'command -v eza' '.zshrc must not replace ls when optional eza is unavailable'
assert_contains "$zshrc" 'command -v bat' '.zshrc must not replace cat when optional bat is unavailable'
assert_contains "$zshrc" 'command -v lazygit' '.zshrc must not define lg when optional LazyGit is unavailable'
assert_not_contains "$repo_dir/README.md" '~/dotfiles' 'README must keep the home directory root clean'
assert_contains "$repo_dir/README.md" '\$HOME/\.local/share/dotfiles' 'README must use the XDG data location'
assert_contains "$repo_dir/README.md" 'Kitty and Zsh use the versions already installed by 42' 'README must state that Kitty and Zsh binaries remain system-provided'

isolated_home="$(mktemp -d)"
trap 'rm -rf "$isolated_home"' EXIT
if ! isolated_error="$(HOME="$isolated_home" PATH=/usr/bin:/bin zsh -dfc "source '$zshrc'" 2>&1)"; then
  fail '.zshrc must load without optional user-local dependencies'
fi
[ -z "$isolated_error" ] || fail ".zshrc emitted errors without optional dependencies: $isolated_error"

pull_line="$(grep -n 'git -C "\$HOME/\.local/share/dotfiles" pull --ff-only' "$repo_dir/README.md" | cut -d: -f1 || true)"
install_line="$(grep -n '^"\$HOME/\.local/share/dotfiles/install\.sh"$' "$repo_dir/README.md" | cut -d: -f1 | tail -n 1 || true)"
exec_line="$(grep -n '^exec zsh$' "$repo_dir/README.md" | cut -d: -f1 | tail -n 1 || true)"
[ -n "$pull_line" ] && [ -n "$install_line" ] && [ -n "$exec_line" ] || fail 'README reinstall command sequence is incomplete'
[ "$pull_line" -lt "$install_line" ] && [ "$install_line" -lt "$exec_line" ] || fail 'README reinstall commands must be ordered pull, install, exec zsh'

lg_alias_count="$(grep -Ec 'alias lg=' "$zshrc" || true)"
[ "$lg_alias_count" -eq 1 ] || fail ".zshrc must define alias lg exactly once (found $lg_alias_count)"

printf 'install contract tests passed\n'
