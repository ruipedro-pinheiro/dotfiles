# ✦ dotfiles

My personal GNOME setup — portable between **Fedora** and **Ubuntu**, terminal-first, keyboard-driven.

![preview](assets/preview-terminal.png)

---

## 🧩 What's included

| Config | Description |
|--------|-------------|
| `starship.toml` | 2-line prompt — fill bar + time on right, `╰─` connector |
| `kitty/` | Terminal emulator — Catppuccin Mauve theme, Monaspace font |
| `fastfetch/` | System info on shell open — image logo, Catppuccin colors |
| `nvim/` | LazyVim setup with custom plugins |
| `zshrc` / `bashrc` | Minimal shell config — Starship, zoxide, eza, bat, lazygit |
| `gnome/` | GNOME dconf dumps + `apply-gnome.sh` to replay the full setup |
| `icons/Hatter-FluentFiles/` | Merged icon theme — Hatter base + Fluent files/folders for Nautilus |
| `fonts/Monaspace/` | MonaspiceAr Nerd Font Mono (Regular, Italic, Bold, BoldItalic) |

---

## 🎨 Theme stack

- **Terminal:** [Kitty](https://sw.kovidgoyal.net/kitty/) · [Catppuccin Mauve](https://github.com/catppuccin/kitty)
- **Prompt:** [Starship](https://starship.rs/)
- **Shell fetch:** [Fastfetch](https://github.com/fastfetch-cli/fastfetch)
- **GTK theme:** Catppuccin-Mauve-Dark
- **Icons:** Hatter-FluentFiles (merged — see below)
- **Cursor:** Bibata-Modern-Ice
- **Font:** [Monaspace Argon Nerd Font](https://monaspace.githubnext.com/)

---

## ⚡ Install

```bash
git clone https://github.com/ruipedro-pinheiro/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
~/.config/gnome/apply-gnome.sh   # optional — GNOME only
```

`install.sh` symlinks everything into `~`. Existing files are backed up to `~/.local/state/dotfiles-install-backups/`.

`apply-gnome.sh` loads the dconf dumps and re-applies the wallpaper. Requires the extensions to be already installed.

### GNOME extensions used

- [Blur my Shell](https://extensions.gnome.org/extension/3193/blur-my-shell/)
- [Dash to Dock](https://extensions.gnome.org/extension/307/dash-to-dock/)
- [User Themes](https://extensions.gnome.org/extension/19/user-themes/)

---

## 🗂️ Icon theme

`Hatter-FluentFiles` is a **merged theme**, not an overlay:

- Base: [Hatter](https://github.com/zigorki/hatter-icon-theme) (most app icons)
- File/folder icons for Nautilus: replaced with [Fluent icons](https://github.com/vinceliuice/Fluent-icon-theme)

Stored in `.local/share/icons/Hatter-FluentFiles/` and symlinked by `install.sh`.

---

## 🖋️ Font

A minimal subset of **MonaspiceAr Nerd Font Mono** is bundled (Regular, Italic, Bold, BoldItalic). `install.sh` runs `fc-cache` automatically.

---

## 📝 Notes

- **No sudo required** — everything installs into `~/.local` or `~/.config`
- Tested on Fedora 43 (Wayland) and Ubuntu 24.04 (X11)
- `Blur my Shell` may conflict with workspace animations on GNOME 49+ — disable app blur if needed
- The `nvim/` config is a standalone [LazyVim](https://lazyvim.org/) setup; it manages its own plugins
