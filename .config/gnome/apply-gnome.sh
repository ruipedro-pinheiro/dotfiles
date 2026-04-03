#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
GNOME_DIR="$REPO_DIR/.config/gnome"
WALLPAPER_URI="file://$HOME/.config/background"

load_if_present() {
  local path_prefix="$1"
  local dump_file="$2"

  if [ -f "$dump_file" ] && command -v dconf >/dev/null 2>&1; then
    dconf load "$path_prefix" < "$dump_file"
  fi
}

load_if_present /org/gnome/desktop/interface/ "$GNOME_DIR/desktop-interface.dconf"
load_if_present /org/gnome/desktop/background/ "$GNOME_DIR/desktop-background.dconf"
load_if_present /org/gnome/desktop/wm/preferences/ "$GNOME_DIR/desktop-wm-preferences.dconf"
load_if_present /org/gnome/shell/ "$GNOME_DIR/shell.dconf"
load_if_present /org/gnome/shell/extensions/dash-to-dock/ "$GNOME_DIR/extensions/dash-to-dock.dconf"
load_if_present /org/gnome/shell/extensions/blur-my-shell/ "$GNOME_DIR/extensions/blur-my-shell.dconf"
load_if_present /org/gnome/shell/extensions/user-theme/ "$GNOME_DIR/extensions/user-theme.dconf"

if command -v gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.desktop.background picture-uri "$WALLPAPER_URI"
  gsettings set org.gnome.desktop.background picture-uri-dark "$WALLPAPER_URI"
fi

printf 'GNOME settings applied from %s\n' "$GNOME_DIR"
