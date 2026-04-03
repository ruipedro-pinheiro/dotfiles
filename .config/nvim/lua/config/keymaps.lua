-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
--
-- LazyVim already provides: <C-s> save, <leader>qq quit, <leader>cf format,
-- <leader>gg lazygit, <leader>ft terminal, buffer navigation, etc.

local map = vim.keymap.set

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │                         General Keymaps                                │
-- └────────────────────────────────────────────────────────────────────────┘

-- Better escape
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
map("i", "jj", "<Esc>", { desc = "Exit insert mode" })

-- Force quit all
map("n", "<leader>Q", "<cmd>qa!<cr>", { desc = "Quit all (force)" })

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │                         System Clipboard                               │
-- └────────────────────────────────────────────────────────────────────────┘

map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
map("n", "<leader>Y", '"+Y', { desc = "Yank line to clipboard" })
map({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from clipboard" })
map({ "n", "v" }, "<leader>P", '"+P', { desc = "Paste before from clipboard" })

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │                         Better Editing                                 │
-- └────────────────────────────────────────────────────────────────────────┘

-- Don't yank on paste in visual mode
map("v", "p", '"_dP', { desc = "Paste without yanking" })

-- Keep cursor centered
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up centered" })
map("n", "n", "nzzzv", { desc = "Next search centered" })
map("n", "N", "Nzzzv", { desc = "Previous search centered" })

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │                         Terminal                                       │
-- └────────────────────────────────────────────────────────────────────────┘

map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

local function terminal_float(cwd)
  Snacks.terminal(nil, {
    cwd = cwd,
    win = {
      position = "float",
      border = "rounded",
      width = 0.88,
      height = 0.82,
    },
  })
end

local function terminal_bottom(cwd)
  Snacks.terminal(nil, {
    cwd = cwd,
    win = {
      position = "bottom",
      border = "top",
      height = 0.32,
    },
  })
end

map("n", "<leader>ft", function()
  terminal_float(LazyVim.root())
end, { desc = "Terminal Float (Root Dir)" })

map("n", "<leader>fT", function()
  terminal_float(vim.fn.getcwd())
end, { desc = "Terminal Float (cwd)" })

map("n", "<leader>tb", function()
  terminal_bottom(LazyVim.root())
end, { desc = "Terminal Bottom (Root Dir)" })

map("n", "<leader>tB", function()
  terminal_bottom(vim.fn.getcwd())
end, { desc = "Terminal Bottom (cwd)" })

map({ "n", "t" }, "<C-/>", function()
  terminal_float(LazyVim.root())
end, { desc = "Terminal Float (Root Dir)" })

map({ "n", "t" }, "<C-_>", function()
  terminal_float(LazyVim.root())
end, { desc = "which_key_ignore" })

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │                     Quick Actions (42 - async)                         │
-- └────────────────────────────────────────────────────────────────────────┘

local function async_cmd(cmd, label)
  vim.notify(label .. "...", vim.log.levels.INFO)
  vim.fn.jobstart(cmd, {
    cwd = vim.fn.getcwd(),
    stderr_buffered = true,
    on_stderr = function(_, data)
      if data and data[1] ~= "" then
        vim.schedule(function()
          vim.notify(table.concat(data, "\n"), vim.log.levels.ERROR)
        end)
      end
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        if code == 0 then
          vim.notify(label .. ": OK", vim.log.levels.INFO)
        else
          vim.notify(label .. ": FAILED (exit " .. code .. ")", vim.log.levels.ERROR)
        end
      end)
    end,
  })
end

-- Compile C file (async, non-blocking — old version froze nvim with !)
map("n", "<F5>", function()
  vim.cmd("write")
  async_cmd({ "cc", "-Wall", "-Werror", "-Wextra", vim.fn.expand("%"), "-o", vim.fn.expand("%:r") }, "Compile")
end, { desc = "Compile C file" })

-- Run compiled file (in terminal split)
map("n", "<F6>", function()
  vim.cmd("split | terminal ./" .. vim.fn.expand("%:r"))
end, { desc = "Run compiled file" })

-- Make (async)
map("n", "<F7>", function() async_cmd({ "make" }, "make") end, { desc = "Run make" })
map("n", "<F8>", function() async_cmd({ "make", "re" }, "make re") end, { desc = "Run make re" })
