#!/usr/bin/env bash

set -Eeuo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
GNOME_DIR="$REPO_DIR/.config/gnome"
WALLPAPER_URI="file://$HOME/.config/background"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"
SNAPSHOT_FILE="$STATE_DIR/dotfiles-gnome-dconf.snapshot"
DCONF_ROLLBACK_READY=0

REQUIRED_EXTENSIONS=(
  'blur-my-shell@aunetx'
  'dash-to-dock@micxgx.gmail.com'
  'user-theme@gnome-shell-extensions.gcampax.github.com'
  'just-perfection-desktop@just-perfection'
  'caffeine@patapon.info'
  'clipboard-indicator@tudmotu.com'
  'appindicatorsupport@rgcjonas.gmail.com'
  'places-menu@gnome-shell-extensions.gcampax.github.com'
  'apps-menu@gnome-shell-extensions.gcampax.github.com'
)

load_if_present() {
  local path_prefix="$1"
  local dump_file="$2"

  if [ -f "$dump_file" ] && command -v dconf >/dev/null 2>&1; then
    dconf load "$path_prefix" < "$dump_file"
  fi
}

wallpaper_enabled() {
  [ "${APPLY_WALLPAPER:-0}" = "1" ]
}

fail_preflight() {
  printf 'GNOME settings not applied: %s\n' "$1" >&2
  exit 1
}

require_file() {
  local path="$1"
  local description="$2"

  [ -s "$path" ] || fail_preflight "Missing required GNOME asset: $description ($path)."
}

preflight_gnome_assets() {
  local installed_extensions extension

  command -v dconf >/dev/null 2>&1 || fail_preflight 'Missing required command: dconf.'
  command -v gsettings >/dev/null 2>&1 || fail_preflight 'Missing required command: gsettings.'
  command -v gnome-extensions >/dev/null 2>&1 || fail_preflight 'Missing required command: gnome-extensions.'

  if wallpaper_enabled; then
    require_file "$HOME/.config/background" 'bundled wallpaper'
  fi
  require_file "$HOME/.themes/Catppuccin-Mauve-Dark/index.theme" 'Catppuccin GTK theme index'
  require_file "$HOME/.icons/Bibata-Modern-Ice/index.theme" 'Bibata cursor index'
  require_file "$HOME/.icons/Hatter-FluentFiles/index.theme" 'Hatter icon index'

  installed_extensions="$(gnome-extensions list)"
  for extension in "${REQUIRED_EXTENSIONS[@]}"; do
    if ! printf '%s\n' "$installed_extensions" | grep -Fxq -- "$extension"; then
      printf 'GNOME extension unavailable: %s\n' "$extension" >&2
    fi
  done
}

snapshot_dconf() {
  mkdir -p "$STATE_DIR"
  dconf dump / > "$SNAPSHOT_FILE"
  DCONF_ROLLBACK_READY=1
}

rollback_dconf() {
  local status=$?

  if [ "$DCONF_ROLLBACK_READY" -eq 1 ] && [ -f "$SNAPSHOT_FILE" ]; then
    printf 'GNOME settings failed; restoring previous dconf snapshot.\n' >&2
    dconf reset -f / || true
    dconf load / < "$SNAPSHOT_FILE" || true
  fi
  exit "$status"
}

preflight_gnome_assets
trap rollback_dconf ERR
snapshot_dconf

load_if_present /org/gnome/desktop/interface/ "$GNOME_DIR/desktop-interface.dconf"
load_if_present /org/gnome/desktop/wm/preferences/ "$GNOME_DIR/desktop-wm-preferences.dconf"
load_if_present /org/gnome/shell/ "$GNOME_DIR/shell.dconf"
load_if_present /org/gnome/shell/extensions/dash-to-dock/ "$GNOME_DIR/extensions/dash-to-dock.dconf"
load_if_present /org/gnome/shell/extensions/blur-my-shell/ "$GNOME_DIR/extensions/blur-my-shell.dconf"
load_if_present /org/gnome/shell/extensions/user-theme/ "$GNOME_DIR/extensions/user-theme.dconf"

if wallpaper_enabled; then
  load_if_present /org/gnome/desktop/background/ "$GNOME_DIR/desktop-background.dconf"
fi

if wallpaper_enabled; then
  gsettings set org.gnome.desktop.background picture-uri "$WALLPAPER_URI"
  gsettings set org.gnome.desktop.background picture-uri-dark "$WALLPAPER_URI"
fi

trap - ERR

printf 'GNOME settings applied from %s\n' "$GNOME_DIR"
