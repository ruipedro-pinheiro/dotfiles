# Neovim Config

Config Neovim basée sur [LazyVim](https://www.lazyvim.org/) pour C/C++, web et usage quotidien, avec headers 42 + bannière perso.

## ✨ Features

- **Theme**: Catppuccin Mocha
- **42 Header**: Header automatique avec `<F1>`
- **Pedro Header**: Bannière perso avec `<F2>`
- **Font**: Monaspace Argon Nerd Font

## 📦 Plugins Principaux

- [LazyVim](https://github.com/LazyVim/LazyVim) - Distribution Neovim
- [42-header.nvim](https://github.com/Diogo-ss/42-header.nvim) - Headers 42
- [blink.cmp](https://github.com/saghen/blink.cmp) - Complétion LSP
- [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) - Explorateur latéral
- [catppuccin](https://github.com/catppuccin/nvim) - Theme

## 🚀 Installation

### Prérequis

```bash
# Neovim >= 0.9.0
brew install neovim

```

### Installation de la config

```bash
# Backup de l'ancienne config si elle existe
mv ~/.config/nvim ~/.config/nvim.backup

# Clone la config
git clone https://github.com/TON_USERNAME/nvim-config.git ~/.config/nvim

# Lance Neovim (les plugins s'installent automatiquement)
nvim
```

### Setup spécifique Mac 42

Sur les Mac de l'école, tu devras peut-être :

1. Installer Neovim via Homebrew (si pas déjà fait)
2. Vérifier que Neovim nightly est bien lancé si tu veux rester sur la dernière base
3. Ajuster `user` et `mail` pour le header 42
4. L'autoformat est désactivé par défaut (format manuel avec `<leader>cf`)

## ⚙️ Configuration Header 42

Dans `lua/plugins/42-tools.lua`, modifie ton user et mail :

```lua
opts = {
  user = "TON_LOGIN",
  mail = "TON_LOGIN@student.42lausanne.ch",
},
```

## ⌨️ Keymaps Essentiels

### Général
- `<leader>` = `Space`
- `<F1>` = Insérer header 42
- `<F2>` = Insérer header Pedro
- `<leader>cf` = Format manuel

### Navigation
- `<leader>e` = Explorer de fichiers
- `<leader>ff` = Find files
- `<leader>fg` = Live grep

### LSP
- `gd` = Go to definition
- `gr` = Go to references
- `K` = Hover documentation

## 📁 Structure

```
~/.config/nvim/
├── init.lua              # Point d'entrée
├── lua/
│   ├── config/
│   │   ├── autocmds.lua  # Autocommands
│   │   ├── keymaps.lua   # Keymaps custom
│   │   ├── lazy.lua      # Config lazy.nvim
│   │   └── options.lua   # Options Vim
│   └── plugins/
│       ├── 42-tools.lua  # Theme + header 42
│       ├── completion.lua
│       ├── headers.lua   # Bannière Pedro
│       ├── lsp.lua
│       └── ui.lua
└── .gitignore
```

## 🎨 Theme

Le theme Catppuccin Mocha fonctionne partout :
- **Arch/HyDE** : Match avec la config Hyprland/Kitty
- **Mac 42** : Fonctionne out-of-the-box avec GNOME

## 📝 Notes

- Le format automatique à la sauvegarde est **désactivé** par défaut
- Les line numbers relatives sont désactivées (preference perso)
- Config testée sur Arch Linux (HyDE) et macOS (GNOME)
- La font Monaspace est optionnelle (fallback sur la font par défaut si absente)
