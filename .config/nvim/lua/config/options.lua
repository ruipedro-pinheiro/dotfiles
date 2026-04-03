-- Options are automatically loaded before lazy.nvim startup
-- Default options: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
--
-- Only set options that DIFFER from LazyVim defaults.
-- LazyVim already sets: relativenumber, number, ignorecase, smartcase,
-- termguicolors, signcolumn, cursorline, splitright, splitbelow,
-- undofile, sidescrolloff, expandtab, clipboard, etc.

-- Tabs (global default: 4 spaces — C/H override to real tabs in autocmds.lua)
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- LazyVim behavior
vim.g.autoformat = false
vim.g.ai_cmp = false
vim.g.lazyvim_explorer = "neo-tree"

-- Search
vim.opt.hlsearch = true

-- UI
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.pumheight = 12

-- Files
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

-- Disable auto-save — Pedro saves explicitly with <C-s>
vim.opt.autowrite = false
vim.opt.autowriteall = false

-- Splits open in the natural direction
vim.opt.splitkeep = "screen"

-- GUI font (Monaspace Argon Nerd Font)
vim.opt.guifont = "MonaspiceAr Nerd Font Mono:h12"

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │                    Float window borders                                │
-- └────────────────────────────────────────────────────────────────────────┘
if vim.fn.has("nvim-0.11") == 1 then
  -- Neovim 0.11+: global winborder applies to ALL float windows
  vim.o.winborder = "rounded"
else
  -- Neovim 0.10: configure borders manually per-feature
  vim.diagnostic.config({
    float = { border = "rounded" },
  })
end

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │         LSP float windows: non-blocking (never steal focus)           │
-- │  Fixes hover/signature windows that capture input on second K press   │
-- └────────────────────────────────────────────────────────────────────────┘
local open_floating_preview = vim.lsp.util.open_floating_preview
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
  opts = opts or {}
  opts.focusable = false
  if vim.fn.has("nvim-0.11") == 0 then
    opts.border = opts.border or "rounded"
  end
  return open_floating_preview(contents, syntax, opts, ...)
end
