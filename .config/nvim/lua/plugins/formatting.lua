return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.default_format_opts = vim.tbl_deep_extend("force", opts.default_format_opts or {}, {
        timeout_ms = 3000,
        lsp_format = "fallback",
      })

      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.c = { "clang_format" }
      opts.formatters_by_ft.cpp = { "clang_format" }
      opts.formatters_by_ft.css = { "prettierd", "prettier" }
      opts.formatters_by_ft.html = { "prettierd", "prettier" }
      opts.formatters_by_ft.javascript = { "prettierd", "prettier" }
      opts.formatters_by_ft.javascriptreact = { "prettierd", "prettier" }
      opts.formatters_by_ft.json = { "prettierd", "prettier" }
      opts.formatters_by_ft.jsonc = { "prettierd", "prettier" }
      opts.formatters_by_ft.markdown = { "prettierd", "prettier" }
      opts.formatters_by_ft.typescript = { "prettierd", "prettier" }
      opts.formatters_by_ft.typescriptreact = { "prettierd", "prettier" }
      opts.formatters_by_ft.yaml = { "prettierd", "prettier" }

      return opts
    end,
  },
  {
    "mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "clang-format",
        "prettierd",
        "prettier",
      })
    end,
  },
}
