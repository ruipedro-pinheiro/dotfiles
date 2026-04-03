-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                      VS Code-like Experience                           ║
-- ║  Removed: flash, persistence, harpoon (all LazyVim built-in/extras)   ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

return {
  -- ┌────────────────────────────────────────────────────────────────────────┐
  -- │                  Surround (Change quotes/brackets easily)              │
  -- └────────────────────────────────────────────────────────────────────────┘
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- cs"' -> change "hello" to 'hello'
        -- ds" -> delete "hello" to hello
        -- ysiw" -> surround word with "
      })
    end,
  },

  -- ┌────────────────────────────────────────────────────────────────────────┐
  -- │                  vim-be-good (Practice vim motions)                    │
  -- └────────────────────────────────────────────────────────────────────────┘
  {
    "ThePrimeagen/vim-be-good",
    cmd = "VimBeGood",
  },

  -- ┌────────────────────────────────────────────────────────────────────────┐
  -- │              Noice UI (cmdline/messages in clean overlays)             │
  -- └────────────────────────────────────────────────────────────────────────┘
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      opts.lsp = opts.lsp or {}
      opts.lsp.override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
      }

      opts.presets = vim.tbl_deep_extend("force", opts.presets or {}, {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      })

      opts.cmdline = vim.tbl_deep_extend("force", opts.cmdline or {}, {
        view = "cmdline_popup",
        format = {
          cmdline = { pattern = "^:", icon = "", lang = "vim" },
          search_down = { kind = "search", pattern = "^/", icon = " " },
          search_up = { kind = "search", pattern = "^%?", icon = " " },
          filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
          lua = { pattern = "^:%s*lua%s+", icon = "", lang = "lua" },
          help = { pattern = "^:%s*he?l?p?%s+", icon = "?" },
        },
      })

      return opts
    end,
  },
}
