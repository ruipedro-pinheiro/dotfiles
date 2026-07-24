# dotfiles

Personal GNOME and development setup for Ubuntu 22.04, GNOME 42, Zsh 5.8.1, and Bash 5.1 at 42.

## Update and reinstall

Run these commands from the existing 42 installation:

```bash
git -C "$HOME/.local/share/dotfiles" pull --ff-only
bash "$HOME/.local/share/dotfiles/install.sh"
exec zsh
```

## Fresh install

Kitty, Zsh, Git, curl, Python 3, `install`, and `sha256sum` must already be available.

```bash
git clone --recurse-submodules git@github.com:ruipedro-pinheiro/dotfiles.git \
  "$HOME/.local/share/dotfiles"
bash "$HOME/.local/share/dotfiles/install.sh"
exec zsh
```

## Installed files

- Zsh, Oh My Zsh, shell plugins, Starship, zoxide, and CLI tools
- Kitty, Fastfetch, LazyGit, Zed, and btop configuration
- Latest Neovim nightly from the `.config/nvim` submodule
- Catppuccin in `~/.themes`, Hatter and Bibata in `~/.icons`, Monaspace in `~/.fonts`
- Bundled GNOME 42 extensions and dconf settings

Kitty and Zsh use the versions already installed by 42. The installer does not use sudo.

## Desktop repair

This skips Neovim, shell plugins, and CLI tool installation:

```bash
bash "$HOME/.local/share/dotfiles/install.sh" --repair-desktop
```

Keep the current wallpaper with:

```bash
APPLY_WALLPAPER=0 bash "$HOME/.local/share/dotfiles/install.sh"
```

## Log

```bash
cat "$HOME/.local/state/dotfiles-install.log"
```

The installer copies every configuration into `$HOME`; it does not create symlinks. Existing files are backed up under `~/.local/state/dotfiles-install-backups/`. Only the newest backup is retained.
