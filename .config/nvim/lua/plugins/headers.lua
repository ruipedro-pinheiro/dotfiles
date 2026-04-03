return {
  {
    "pedro-header",
    virtual = true,
    lazy = false,
    config = function()
      local function updated_line(time)
        return "/*                        UPDATED: " .. time .. "                        */"
      end

      local function build_header(time)
        return {
          "/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */",
          "/*                           ____           __                                */",
          "/*                          / __ \\___  ____/ /_______                         */",
          "/*                         / /_/ / _ \\/ __  / ___/ __ \\                       */",
          "/*                        / ____/  __/ /_/ / /  / /_/ /                       */",
          "/*                       /_/    \\___/\\____/_/   \\____/                        */",
          "/*                                                                            */",
          "/*                               PEDRO PINHEIRO                               */",
          "/*                             SOFTWARE ENGINEER                              */",
          "/*                                                                            */",
          "/*             C  •  C++  •  WEB  •  GITHUB.COM/RUIPEDRO-PINHEIRO             */",
          "/*                                                                            */",
          updated_line(time),
          "/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */",
          "",
        }
      end

      local function insert_header()
        local time = vim.fn.strftime("%Y/%m/%d %H:%M:%S")
        vim.api.nvim_buf_set_lines(0, 0, 0, false, build_header(time))
        vim.opt_local.list = false
      end

      local function update_header(args)
        local max_lines = math.min(vim.api.nvim_buf_line_count(args.buf), 20)
        local lines = vim.api.nvim_buf_get_lines(args.buf, 0, max_lines, false)
        local has_pedro_header = false
        local replace_until = 0

        for index, text in ipairs(lines) do
          if text:match("PEDRO PINHEIRO") then
            has_pedro_header = true
          end

          if index == 1 and not text:match("^/%* ") then
            break
          end

          if text:match("^/%* ") or text == "" then
            replace_until = index
          else
            break
          end
        end

        if not has_pedro_header or replace_until == 0 then
          return
        end

        local time = vim.fn.strftime("%Y/%m/%d %H:%M:%S")
        vim.api.nvim_buf_set_lines(args.buf, 0, replace_until, false, build_header(time))
      end

      vim.keymap.set("n", "<F2>", insert_header, { desc = "Insert Pedro Header" })

      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("PedroHeader", { clear = true }),
        callback = update_header,
      })
    end,
  },
}
