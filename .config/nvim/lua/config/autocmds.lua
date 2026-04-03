-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- LazyVim already provides: highlight_yank, resize_splits, last_loc,
-- close_with_q, checktime, wrap_spell, auto_create_dir, etc.

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │                      C filetype settings                               │
-- └────────────────────────────────────────────────────────────────────────┘
augroup("CIndent", { clear = true })
autocmd("FileType", {
  group = "CIndent",
  pattern = { "c" },
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.colorcolumn = "80"
  end,
})

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │                      Remove trailing whitespace                        │
-- └────────────────────────────────────────────────────────────────────────┘
augroup("TrimWhitespace", { clear = true })
autocmd("BufWritePre", {
  group = "TrimWhitespace",
  pattern = { "*.c", "*.h" },
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │                      Diagnostic float on cursor hold                   │
-- └────────────────────────────────────────────────────────────────────────┘
augroup("DiagnosticFloat", { clear = true })
autocmd("CursorHold", {
  group = "DiagnosticFloat",
  callback = function()
    local line = vim.api.nvim_win_get_cursor(0)[1] - 1
    if vim.tbl_isempty(vim.diagnostic.get(0, { lnum = line })) then
      return
    end
    vim.diagnostic.open_float(nil, {
      scope = "cursor",
      focusable = false,
      close_events = { "CursorMoved", "CursorMovedI", "BufHidden", "InsertEnter", "FocusLost" },
    })
  end,
})
