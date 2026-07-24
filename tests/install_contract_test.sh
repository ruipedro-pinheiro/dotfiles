#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
install_sh="$repo_dir/install.sh"
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
bash -n "$zshrc"

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

last_download_line="$(grep -n '^install_latest_starship$' "$install_sh" | cut -d: -f1)"
activate_line="$(grep -n '^activate_tools$' "$install_sh" | cut -d: -f1)"
shell_line="$(grep -n '^prepare_shell$' "$install_sh" | cut -d: -f1)"
[ -n "$last_download_line" ] && [ -n "$activate_line" ] || fail 'tool staging order markers missing'
[ "$last_download_line" -lt "$activate_line" ] || fail 'old tools must remain until every replacement is staged'
[ -n "$shell_line" ] && [ "$last_download_line" -lt "$shell_line" ] || fail 'release failures must occur before shell configuration changes'

assert_contains "$zshrc" 'dangerously-load-development-channels server:ai-bridge-channel' '.zshrc must include Claude ai-bridge alias'
assert_contains "$zshrc" 'opencode\(\)' '.zshrc must include opencode fixed-port wrapper'
assert_contains "$zshrc" '\$HOME/\.opencode/bin' '.zshrc must use $HOME for opencode PATH'
assert_contains "$zshrc" '\$HOME/\.spicetify' '.zshrc must use $HOME for spicetify PATH'
assert_not_contains "$zshrc" 'MAX_THINKING_TOKENS|CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING|CLAUDE_CODE_EFFORT_LEVEL' '.zshrc must remove old Claude thinking env'

lg_alias_count="$(grep -Ec '^alias lg=' "$zshrc")"
[ "$lg_alias_count" -eq 1 ] || fail ".zshrc must define alias lg exactly once (found $lg_alias_count)"

printf 'install contract tests passed\n'
