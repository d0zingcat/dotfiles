-- formatting.lua - 代码格式化（conform.nvim）

return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = { "n", "v" },
        desc = "格式化代码",
      },
      {
        "<leader>uf",
        function()
          vim.b.disable_autoformat = not vim.b.disable_autoformat
          vim.notify(
            "当前缓冲区自动格式化 " .. (vim.b.disable_autoformat and "已禁用" or "已启用"),
            vim.log.levels.INFO
          )
        end,
        desc = "切换当前缓冲区自动格式化",
      },
      {
        "<leader>uF",
        function()
          vim.g.disable_autoformat = not vim.g.disable_autoformat
          vim.notify(
            "全局自动格式化 " .. (vim.g.disable_autoformat and "已禁用" or "已启用"),
            vim.log.levels.INFO
          )
        end,
        desc = "切换全局自动格式化",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        go = { "goimports", "gofumpt" },
        rust = { "rustfmt" },
        python = { "isort", "ruff_format" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd" },
        jsonc = { "prettierd" },
        html = { "prettierd" },
        css = { "prettierd" },
        scss = { "prettierd" },
        yaml = { "prettierd" },
        markdown = { "prettierd" },
        sh = { "shfmt" },
        bash = { "shfmt" },
      },

      formatters = {
        stylua = {
          args = { "--indent-type", "Spaces", "--indent-width", "2", "-" },
        },
        shfmt = {
          args = { "-i", "2", "-" },
        },
      },

      format_on_save = function(bufnr)
        if vim.b[bufnr].disable_autoformat or vim.g.disable_autoformat then
          return
        end
        return { timeout_ms = 3000, lsp_format = "fallback" }
      end,
    },
  },
}
