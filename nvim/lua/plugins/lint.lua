-- lint.lua - 代码静态检查（nvim-lint）

return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        python = { "ruff" },
        lua = { "selene" },
        go = { "golangcilint" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        markdown = { "markdownlint" },
        yaml = { "yamllint" },
        sh = { "shellcheck" },
        bash = { "shellcheck" },
      }

      if vim.fn.executable("hadolint") == 1 then
        lint.linters_by_ft.dockerfile = { "hadolint" }
      end

      local lint_augroup = vim.api.nvim_create_augroup("nvim_lint", { clear = true })

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })

      vim.api.nvim_create_user_command("Lint", function()
        lint.try_lint()
      end, { desc = "手动触发代码检查" })
    end,
  },
}
