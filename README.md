# dotfiles

My personal GNOME setup — not meant to be used as-is, but feel free to poke around or borrow whatever's useful. Primarily maintained on Fedora 43 / GNOME 49 (Wayland). Ubuntu 24.04 (X11) is tested occasionally and not guaranteed to work.

![Kitty terminal running fastfetch — distro logo on the left, system info on the right, Starship prompt below](assets/preview-terminal.png)

---

## Requirements

`install.sh` requires no sudo — it only creates symlinks into `~`. The following tools need to be available first.

**Fedora:**
```bash
sudo dnf install kitty neovim fastfetch eza bat lazygit zsh
```

**Ubuntu:** tools are expected to already be present. `install.sh` handles the rest without sudo.

After installing zsh, set it as your default shell and log out for the change to take effect:
```bash
chsh -s $(which zsh)
```

**Separate installers (required on both distros):**

> Run `install.sh` before running the Oh My Zsh installer — Oh My Zsh will offer to replace `.zshrc` and will overwrite the one from this repo if you let it. Say no when prompted.

- [Starship](https://starship.rs/) — `curl -sS https://starship.rs/install.sh | sh`
- [Oh My Zsh](https://ohmyz.sh/) — `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
- [zoxide](https://github.com/ajeetdsouza/zoxide) — `curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh`
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) — `git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions`
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) — `git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting`

**GNOME theme and cursor** (not in any package manager — install manually):
- GTK: [Catppuccin GTK](https://github.com/catppuccin/gtk) — install `Catppuccin-Mauve-Dark` to `~/.local/share/themes/`
- Cursor: [Bibata-Modern-Ice](https://github.com/ful1e5/Bibata_Cursor) — install to `~/.local/share/icons/`

---

## Install

```bash
git clone https://github.com/ruipedro-pinheiro/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

Creates symlinks pointing into `~/dotfiles` — `.zshrc` and `.bashrc` land in `~`, everything else goes under `~/.config/` or `~/.local/share/`. The font cache is updated automatically.

Before replacing anything, existing files are moved to `~/.local/state/dotfiles-install-backups/<YYYYMMDD-HHMMSS>/`. Running it again is safe: symlinks that already point to the right target are skipped; anything that drifted gets a new timestamped backup before being replaced.

To apply GNOME settings, install all extensions listed in the [GNOME extensions](#gnome-extensions) section first, then:

```bash
~/.config/gnome/apply-gnome.sh
```

Loads dconf dumps for interface settings (GTK theme, cursor, icon theme, font), desktop background, window manager preferences, shell config, and extension settings for Dash to Dock, Blur my Shell, and User Themes. The other extensions in the list are active but their settings aren't in the dump — they'll load with defaults. Finishes by overriding the wallpaper path via `gsettings` to point at `~/.config/background` for the current user (both light and dark variants).

---

## What's included

| Path | Notes |
|------|-------|
| `.zshrc` | Starship + zoxide init, eza/bat/lazygit aliases, runs fastfetch on first interactive shell start |
| `.bashrc` | Re-execs zsh — nothing else runs |
| `.config/starship.toml` | 2-line prompt — fill bar pushes time to the right edge, `╰─` connector on line 2 |
| `.config/kitty/` | Catppuccin Mocha, Monaspace Argon 15pt |
| `.config/fastfetch/` | kitty-direct image protocol, Catppuccin colors — active image is `wallhaven-pol5qp-fastfetch-portrait-soft.png`, other variants included |
| `.config/nvim/` | LazyVim base + blink.cmp, conform, nvim-surround, wakatime (requires a [WakaTime API key](https://wakatime.com/settings/account) in `~/.wakatime.cfg`) |
| `.config/gnome/` | dconf dumps + `apply-gnome.sh` |
| `.config/background` | Wallpaper file — `install.sh` links it into `~/.config/background`; `apply-gnome.sh` points GNOME at that path |
| `.local/share/icons/Hatter-FluentFiles/` | Merged icon theme — Hatter base, Fluent file/folder icons |
| `.local/share/fonts/Monaspace/` | MonaspiceAr Nerd Font Mono — Regular, Italic, Bold, BoldItalic |

The fastfetch config includes `localip` and `publicip` modules. Remove them if you don't want those showing up in screenshots.

---

## Theme

| Property | Value |
|----------|-------|
| GTK | [Catppuccin-Mauve-Dark](https://github.com/catppuccin/gtk) |
| Terminal + Editor | Catppuccin Mocha (Kitty + Neovim) |
| Icons | Hatter-FluentFiles |
| Cursor | [Bibata-Modern-Ice](https://github.com/ful1e5/Bibata_Cursor) |
| Font | [Monaspace Argon Nerd Font](https://monaspace.githubnext.com/) |
| Wallpaper | [ArtStation — Moe Wanders](https://www.artstation.com/artwork/OGaRR6) |

---

## GNOME extensions

Listed as of the included dconf dump. Install from [extensions.gnome.org](https://extensions.gnome.org) or via [Extension Manager](https://flathub.org/apps/com.mattjakeman.ExtensionManager).

- [Blur my Shell](https://extensions.gnome.org/extension/3193/blur-my-shell/) — disable app blur if it conflicts with workspace animations on GNOME 49
- [Dash to Dock](https://extensions.gnome.org/extension/307/dash-to-dock/)
- [User Themes](https://extensions.gnome.org/extension/19/user-themes/)
- [Just Perfection](https://extensions.gnome.org/extension/3843/just-perfection/)
- [Caffeine](https://extensions.gnome.org/extension/517/caffeine/)
- [Clipboard Indicator](https://extensions.gnome.org/extension/779/clipboard-indicator/)
- [AppIndicator Support](https://extensions.gnome.org/extension/615/appindicator-support/)
- [Places Status Indicator](https://extensions.gnome.org/extension/8/places-status-indicator/) — superseded by built-in GNOME features, may not function on GNOME 49+
- [Applications Menu](https://extensions.gnome.org/extension/6/applications-menu/) — superseded by built-in GNOME features, may not function on GNOME 49+

---

## Icon theme

`Hatter-FluentFiles` is a merged theme rather than a stacked overlay (where one theme falls back to another). The Hatter and Fluent icon files were combined into a single theme directory: [Hatter](https://github.com/zigorki/hatter-icon-theme) provides the app icons, while file and folder icons are taken from [Fluent](https://github.com/vinceliuice/Fluent-icon-theme) to give Nautilus a more consistent look.
