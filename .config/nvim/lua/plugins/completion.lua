return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        menu = {
          border = "rounded",
          winblend = 0,
          winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
        },
        accept = {
          auto_brackets = {
            enabled = false,
          },
        },
        documentation = {
          auto_show = false,
          auto_show_delay_ms = 120,
          window = {
            border = "rounded",
            winblend = 0,
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,EndOfBuffer:NormalFloat",
          },
        },
        ghost_text = {
          enabled = false,
        },
      },
      signature = {
        enabled = true,
        window = {
          border = "rounded",
          winblend = 0,
          winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
          show_documentation = false,
        },
      },
      sources = {
        default = { "lsp", "path", "buffer" },
        providers = {
          lsp = {
            transform_items = function(_, items)
              return vim.tbl_filter(function(item)
                return item.kind ~= require("blink.cmp.types").CompletionItemKind.Snippet
              end, items)
            end,
          },
        },
      },
    },
  },
}
