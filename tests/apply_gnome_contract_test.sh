#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
apply_gnome_sh="$repo_dir/.config/gnome/apply-gnome.sh"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

make_fake_commands() {
  local bin_dir="$1"
  cat > "$bin_dir/dconf" <<'EOF'
#!/usr/bin/env bash
printf 'dconf %s\n' "$*" >> "$COMMAND_LOG"
case "$1" in
  dump)
    if [ "${DCONF_EMPTY_SNAPSHOT:-0}" != 1 ]; then
      printf '[snapshot]\nvalue=true\n'
    fi
    ;;
  load)
    cat >/dev/null
    if [ "${DCONF_FAIL_ON_PREFIX:-}" = "$2" ]; then
      exit 19
    fi
    ;;
  *) exit 2 ;;
esac
EOF
  cat > "$bin_dir/gsettings" <<'EOF'
#!/usr/bin/env bash
printf 'gsettings %s\n' "$*" >> "$COMMAND_LOG"
EOF
  cat > "$bin_dir/gnome-extensions" <<'EOF'
#!/usr/bin/env bash
if [ "$1" = list ]; then
  cat "$GNOME_EXTENSIONS_LIST"
else
  printf 'gnome-extensions %s\n' "$*" >> "$COMMAND_LOG"
fi
EOF
  chmod +x "$bin_dir/dconf" "$bin_dir/gsettings" "$bin_dir/gnome-extensions"
}

prepare_home_assets() {
  local home_dir="$1"
  mkdir -p \
    "$home_dir/.config" \
    "$home_dir/.themes/Catppuccin-Mauve-Dark" \
    "$home_dir/.icons/Bibata-Modern-Ice" \
    "$home_dir/.icons/Hatter-FluentFiles"
  printf 'wallpaper\n' > "$home_dir/.config/background"
  printf '[theme]\n' > "$home_dir/.themes/Catppuccin-Mauve-Dark/index.theme"
  printf '[cursor]\n' > "$home_dir/.icons/Bibata-Modern-Ice/index.theme"
  printf '[icons]\n' > "$home_dir/.icons/Hatter-FluentFiles/index.theme"
}

write_extensions_list() {
  local list_file="$1"
  cat > "$list_file" <<'EOF'
blur-my-shell@aunetx
dash-to-dock@micxgx.gmail.com
user-theme@gnome-shell-extensions.gcampax.github.com
just-perfection-desktop@just-perfection
caffeine@patapon.info
clipboard-indicator@tudmotu.com
appindicatorsupport@rgcjonas.gmail.com
places-menu@gnome-shell-extensions.gcampax.github.com
apps-menu@gnome-shell-extensions.gcampax.github.com
EOF
}

run_apply() {
  local temp_dir="$1"
  shift
  HOME="$temp_dir/home" \
  XDG_STATE_HOME="$temp_dir/state" \
  COMMAND_LOG="$temp_dir/commands.log" \
  GNOME_EXTENSIONS_LIST="$temp_dir/extensions.txt" \
  PATH="$temp_dir/bin:$PATH" \
  "$@" "$apply_gnome_sh"
}

with_fixture() {
  local temp_dir
  temp_dir="$(mktemp -d)"
  mkdir -p "$temp_dir/bin" "$temp_dir/home" "$temp_dir/state"
  : > "$temp_dir/commands.log"
  make_fake_commands "$temp_dir/bin"
  write_extensions_list "$temp_dir/extensions.txt"
  prepare_home_assets "$temp_dir/home"
  printf '%s\n' "$temp_dir"
}

temp_dir="$(with_fixture)"
rm -f "$temp_dir/home/.themes/Catppuccin-Mauve-Dark/index.theme"
if run_apply "$temp_dir" env >/"$temp_dir/out" 2>"$temp_dir/err"; then
  fail 'apply-gnome must fail when required theme assets are missing'
fi
grep -q 'Missing required GNOME asset' "$temp_dir/err" || fail 'missing asset error must be clear'
[ ! -s "$temp_dir/commands.log" ] || fail 'preflight failure must not mutate dconf or gsettings'

temp_dir="$(with_fixture)"
grep -Fvx 'clipboard-indicator@tudmotu.com' "$temp_dir/extensions.txt" > "$temp_dir/extensions.filtered"
mv "$temp_dir/extensions.filtered" "$temp_dir/extensions.txt"
run_apply "$temp_dir" env >"$temp_dir/out" 2>"$temp_dir/err"
grep -q 'GNOME extension unavailable: clipboard-indicator@tudmotu.com' "$temp_dir/err" || fail 'missing extensions must warn without blocking desktop settings'

temp_dir="$(with_fixture)"
run_apply "$temp_dir" env >/"$temp_dir/out" 2>"$temp_dir/err"
grep -q 'dconf load /org/gnome/desktop/background/' "$temp_dir/commands.log" || fail 'wallpaper dconf must apply by default'
grep -q 'gsettings set org.gnome.desktop.background picture-uri file://' "$temp_dir/commands.log" || fail 'wallpaper gsettings must apply by default'
[ -f "$temp_dir/state/dotfiles-gnome-dconf.snapshot" ] || fail 'dconf safety snapshot missing'

temp_dir="$(with_fixture)"
run_apply "$temp_dir" env APPLY_WALLPAPER=0 >/"$temp_dir/out" 2>"$temp_dir/err"
if grep -q '/org/gnome/desktop/background/' "$temp_dir/commands.log"; then
  fail 'wallpaper dconf must be skipped when APPLY_WALLPAPER=0'
fi
if grep -q 'org.gnome.desktop.background picture-uri' "$temp_dir/commands.log"; then
  fail 'wallpaper gsettings must be skipped when APPLY_WALLPAPER=0'
fi

temp_dir="$(with_fixture)"
if run_apply "$temp_dir" env DCONF_FAIL_ON_PREFIX=/org/gnome/desktop/background/ >/"$temp_dir/out" 2>"$temp_dir/err"; then
  fail 'apply-gnome must fail when a dconf load fails'
fi
grep -q 'GNOME settings failed; restoring previous dconf snapshot' "$temp_dir/err" || fail 'dconf failure must trigger rollback message'
grep -q 'dconf reset -f /' "$temp_dir/commands.log" || fail 'dconf failure must clear partially applied keys before rollback'
grep -q 'dconf load /$' "$temp_dir/commands.log" || fail 'dconf failure must restore the root snapshot'

temp_dir="$(with_fixture)"
if run_apply "$temp_dir" env DCONF_EMPTY_SNAPSHOT=1 DCONF_FAIL_ON_PREFIX=/org/gnome/desktop/background/ >"$temp_dir/out" 2>"$temp_dir/err"; then
  fail 'apply-gnome must fail when a dconf load fails with an empty original database'
fi
grep -q 'dconf reset -f /' "$temp_dir/commands.log" || fail 'an empty snapshot must still clear partially applied dconf keys'

printf 'apply GNOME contract tests passed\n'
