# Nvim Cheatsheet — Pedro (LazyVim + Custom)

> Ouvre dans nvim : `nvim ~/.config/nvim/cheatsheet.md`
> Leader = `<Space>`

---

## VIM FONDAMENTAUX (a drill avec vim-be-good)

### Operateurs (combiner avec motions/text objects)

| Key | Action |
|-----|--------|
| `d` | Delete |
| `c` | Change (delete + insert mode) |
| `y` | Yank (copie dans registre vim) |
| `v` | Visual select |
| `>` / `<` | Indent / Dedent |
| `gu` / `gU` | Lowercase / Uppercase |

### Motions (ou aller)

| Key | Action |
|-----|--------|
| `w` / `b` | Mot suivant / precedent |
| `e` | Fin du mot |
| `W` / `B` / `E` | Pareil mais WORD (ignore ponctuation) |
| `0` / `$` | Debut / fin de ligne |
| `^` | Premier char non-blanc |
| `f{c}` / `F{c}` | Jump au char `c` (avant/arriere) |
| `t{c}` / `T{c}` | Jump juste avant char `c` |
| `;` / `,` | Repeter f/t suivant / precedent |
| `gg` / `G` | Debut / fin du fichier |
| `{` / `}` | Paragraphe precedent / suivant |
| `%` | Parenthese/bracket correspondante |
| `H` / `M` / `L` | Haut / milieu / bas de l'ecran |

### Text Objects (le vrai power move)

Prefixe `i` = inside, `a` = around (inclut delimiteurs)

| Key | Action | Exemple |
|-----|--------|---------|
| `iw` / `aw` | Mot | `diw` = delete mot sous curseur |
| `i"` / `a"` | Entre guillemets | `ci"` = change contenu entre `"` |
| `i'` / `a'` | Entre apostrophes | `di'` = delete entre `'` |
| `i)` / `a)` | Entre parentheses | `ci)` = change contenu entre `()` |
| `i]` / `a]` | Entre crochets | `da]` = delete `[]` inclus |
| `i}` / `a}` | Entre accolades | `ci}` = change dans `{}` |
| `it` / `at` | Tag HTML/XML | `dit` = delete entre tags |
| `ip` / `ap` | Paragraphe | `dap` = delete paragraphe |
| `is` / `as` | Phrase (sentence) | `cis` = change phrase |

### Combos essentiels

| Combo | Action |
|-------|--------|
| `ciw` | Change le mot sous le curseur |
| `ci"` | Change le contenu entre `"` |
| `di)` | Delete le contenu entre `()` |
| `da}` | Delete les `{}` et leur contenu |
| `yiw` | Yank le mot |
| `vi)` | Selectionne visuellement entre `()` |
| `ct;` | Change jusqu'au `;` |
| `df,` | Delete jusqu'a `,` inclus |
| `.` | **Repeter** la derniere action |
| `u` / `<C-r>` | Undo / Redo |

---

## TES KEYMAPS CUSTOM

### General

| Key | Action |
|-----|--------|
| `jk` / `jj` | Escape (insert mode) |
| `<C-s>` | Save (+ format si fichier C) |
| `<Space>q` | Quit |
| `<Space>Q` | Force quit all |

### Clipboard (separe du registre vim)

| Key | Action |
|-----|--------|
| `<Space>y` | Yank vers clipboard systeme |
| `<Space>Y` | Yank ligne vers clipboard |
| `<Space>p` | Paste depuis clipboard |
| `<Space>P` | Paste avant depuis clipboard |
| `p` (visual) | Paste sans ecraser le registre |
| `dd` / `d{motion}` | Delete → registre vim (PAS clipboard) |

### Navigation centree

| Key | Action |
|-----|--------|
| `<C-d>` | Scroll demi-page bas (centre) |
| `<C-u>` | Scroll demi-page haut (centre) |
| `n` / `N` | Recherche suivant/precedent (centre) |

### Headers, build et format

| Key | Action |
|-----|--------|
| `F1` | Inserer le header 42 |
| `F2` | Inserer la bannière Pedro |
| `<Space>cf` | Format manuel |
| `F5` | Compile fichier C (`cc -Wall -Werror -Wextra`) |
| `F6` | Run le binaire compile |
| `F7` | `make` |
| `F8` | `make re` |

### Terminal

| Key | Action |
|-----|--------|
| `<Space>tt` | Ouvrir terminal |
| `<Esc><Esc>` | Quitter mode terminal |

---

## HARPOON (navigation rapide entre fichiers)

| Key | Action |
|-----|--------|
| `<Space>a` | Ajouter fichier a la liste |
| `<C-e>` | Menu Harpoon (voir/reordonner) |
| `<C-1>` | Switch vers fichier 1 |
| `<C-2>` | Switch vers fichier 2 |
| `<C-3>` | Switch vers fichier 3 |
| `<C-4>` | Switch vers fichier 4 |

**Workflow** : ouvre tes 3-4 fichiers principaux, `<Space>a` chacun, puis `<C-1/2/3/4>` pour switcher instantanement.

---

## LAZYVIM DEFAULTS (les plus utiles)

### Fichiers & Navigation

| Key | Action |
|-----|--------|
| `<Space>e` | Explorateur (neo-tree) |
| `<Space>ff` | Find files (telescope) |
| `<Space>fg` | Live grep (chercher du texte) |
| `<Space>fb` | Buffers ouverts |
| `<Space>fr` | Fichiers recents |
| `<Space>/` | Grep dans le projet |
| `<Space>,` | Switcher de buffer |
| `<Space>:` | Historique commandes |

### Fenetres

| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | Naviguer entre fenetres |
| `<C-Up/Down/Left/Right>` | Resize fenetre |
| `<Space>-` | Split horizontal |
| `<Space>\|` | Split vertical |

### LSP (quand un serveur est attache)

| Key | Action |
|-----|--------|
| `K` | Hover (doc du symbole) |
| `gd` | Go to definition |
| `gr` | References |
| `gI` | Go to implementation |
| `gy` | Go to type definition |
| `gD` | Declaration |
| `gK` | Signature help |
| `<Space>ca` | Code action |
| `<Space>cr` | Rename |
| `<Space>cd` | Line diagnostic |
| `]d` / `[d` | Diagnostic suivant/precedent |

### Git (LazyVim + lazygit)

| Key | Action |
|-----|--------|
| `<Space>gg` | Lazygit (TUI git complet) |
| `<Space>gf` | Git files |
| `<Space>gc` | Git commits |
| `<Space>gs` | Git status |
| `]h` / `[h` | Hunk suivant/precedent (gitsigns) |

### Toggles

| Key | Action |
|-----|--------|
| `<Space>uf` | Toggle auto-format |
| `<Space>us` | Toggle spelling |
| `<Space>uw` | Toggle word wrap |
| `<Space>ul` | Toggle line numbers |
| `<Space>ud` | Toggle diagnostics |

---

## PLUGINS

### Flash (jump ultra-rapide)

| Key | Action |
|-----|--------|
| `s` | Flash jump — tape 2 chars, jump direct |
| `S` | Flash treesitter — select par node |

### Surround

| Key | Action | Exemple |
|-----|--------|---------|
| `cs{old}{new}` | Change surrounding | `cs"'` : `"hello"` → `'hello'` |
| `ds{char}` | Delete surrounding | `ds"` : `"hello"` → `hello` |
| `ysiw{char}` | Add surrounding | `ysiw"` : `hello` → `"hello"` |
| `ysa{obj}{char}` | Add around obj | `ysa)"` : `(foo)` → `"(foo)"` |

### Session

| Key | Action |
|-----|--------|
| `<Space>qs` | Restore session (dossier courant) |
| `<Space>ql` | Restore derniere session |

---

## VIM-BE-GOOD (entrainement)

Lance dans nvim : `:VimBeGood`

Modes disponibles :
- **hjkl** — navigation basique
- **word** — motions w/b/e
- **delete** — d + motions
- **change** — c + motions (le plus utile a drill)

---

## ORDRE D'APPRENTISSAGE RECOMMANDE

1. **Semaine 1** : `hjkl`, `w/b/e`, `dd`, `cc`, `ciw`, `ci"`, `di)`, `.`
2. **Semaine 2** : `f/t` + `;`, text objects (`iw`, `i"`, `i)`, `i}`), `<C-d>/<C-u>`
3. **Semaine 3** : Flash (`s`), Harpoon (`<Space>a`, `<C-1..4>`), Telescope (`<Space>ff/fg`)
4. **Semaine 4** : Surround (`cs/ds/ys`), LSP (`gd`, `K`, `<Space>ca/cr`), macros (`q`)
5. **Ongoing** : `:VimBeGood` chaque jour 10 min jusqu'a ce que ce soit instinctif
