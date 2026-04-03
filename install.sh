#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-install-backups/$(date +%Y%m%d-%H%M%S)"

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

link_item "$REPO_DIR/.bashrc" "$HOME/.bashrc"
link_item "$REPO_DIR/.zshrc" "$HOME/.zshrc"
link_item "$REPO_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
link_item "$REPO_DIR/.config/background" "$HOME/.config/background"
link_item "$REPO_DIR/.config/gnome" "$HOME/.config/gnome"
link_item "$REPO_DIR/.config/kitty" "$HOME/.config/kitty"
link_item "$REPO_DIR/.config/fastfetch" "$HOME/.config/fastfetch"
link_item "$REPO_DIR/.config/nvim" "$HOME/.config/nvim"
link_item "$REPO_DIR/.local/share/fonts/Monaspace" "$HOME/.local/share/fonts/Monaspace"
link_item "$REPO_DIR/.local/share/icons/Hatter-FluentFiles" "$HOME/.local/share/icons/Hatter-FluentFiles"

if command -v fc-cache >/dev/null 2>&1; then
  fc-cache -f "$HOME/.local/share/fonts" >/dev/null
fi

printf 'Dotfiles linked from %s\n' "$REPO_DIR"
printf 'Backups stored in %s\n' "$BACKUP_ROOT"
