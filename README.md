# dotfiles

My personal GNOME setup — not meant to be used as-is, but feel free to poke around or borrow whatever's useful. Primarily maintained on Fedora 43 / GNOME 49 (Wayland). Ubuntu 24.04 (X11) is tested occasionally and not guaranteed to work.

![Kitty terminal running fastfetch — distro logo on the left, system info on the right, Starship prompt below](assets/preview-terminal.png)

---

## Requirements

`install.sh` requires no sudo. It creates symlinks, initializes the Neovim
submodule, and installs user-local CLI tools. The following tools need to be
available first.

**Fedora:**
```bash
sudo dnf install kitty zsh git curl tar python3
```

**Ubuntu:** Kitty and zsh must be available. The standard 42 environment also
needs `git`, `curl`, `tar`, `python3`, `find`, `install`, and `sha256sum`.

The installer fetches verified current releases of bat, eza, Fastfetch,
Starship, zoxide, LazyGit, LazyCommit, and portable GDB. It also initializes Oh
My Zsh, zsh-autosuggestions, zsh-syntax-highlighting, and Neovim nightly.

After installing zsh, set it as your default shell and log out for the change to take effect:
```bash
chsh -s $(which zsh)
```

**GNOME theme and cursor** (not in any package manager — install manually):
- GTK: [Catppuccin GTK](https://github.com/catppuccin/gtk) — install `Catppuccin-Mauve-Dark` to `~/.local/share/themes/`
- Cursor: [Bibata-Modern-Ice](https://github.com/ful1e5/Bibata_Cursor) — install to `~/.local/share/icons/`

---

## Install

```bash
git clone --recurse-submodules https://github.com/ruipedro-pinheiro/dotfiles \
  "$HOME/.local/share/dotfiles"
"$HOME/.local/share/dotfiles/install.sh"
```

Creates symlinks pointing into `~/.local/share/dotfiles`. Only the hidden shell
files `.zshrc` and `.bashrc` land directly in `~`; everything else stays under
`~/.config/` or `~/.local/share/`. A clone made without `--recurse-submodules`
is supported: `install.sh` initializes the submodules automatically. The font
cache is updated automatically.

Neovim comes from the
[`ruipedro-pinheiro/nvim`](https://github.com/ruipedro-pinheiro/nvim)
submodule. Its installer removes previous Neovim data and installs the latest
nightly plus its isolated toolchain. Stale user-local copies of LazyGit,
LazyCommit, zoxide, and GDB are removed, then replaced with the latest verified
GitHub releases in `~/.local/bin`. System installations are left untouched.

Before replacing anything, existing files are moved to
`~/.local/state/dotfiles-install-backups/<YYYYMMDD-HHMMSS>/`. Only the newest
backup is retained to fit restricted home quotas. The installer also requires
at least 2 GiB of free space before downloading or changing the setup.

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
| `.config/kitty/` | Catppuccin Mocha, Monaspace Argon 16pt |
| `.config/fastfetch/` | kitty-direct image protocol, Catppuccin colors — active image is `wallhaven-pol5qp-fastfetch-portrait-soft.png`, other variants included |
| `.config/nvim/` | Git submodule for the standalone Neovim nightly configuration and installer |
| `.config/lazygit/` | LazyGit commands backed by LazyCommit |
| `.config/zed/` | Zed editor theme, Vim mode, and privacy settings |
| `.config/btop/` | btop layout, theme, and monitoring preferences |
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
