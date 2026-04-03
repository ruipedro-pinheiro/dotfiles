return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = false,
        float = {
          border = "rounded",
          source = "if_many",
        },
      },
      inlay_hints = {
        enabled = false,
      },
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=never",
            "--completion-style=detailed",
            "--function-arg-placeholders=0",
            "--fallback-style=llvm",
          },
          init_options = {
            usePlaceholders = false,
            completeUnimported = true,
            clangdFileStatus = true,
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = "Disable",
              },
            },
          },
        },
      },
    },
  },
}
