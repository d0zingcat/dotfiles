-- null-ls.lua - 格式化与诊断
return {
  {
    "nvimtools/none-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = function()
      local null_ls = require("null-ls")
      return {
        sources = {
          -- Go
          null_ls.builtins.formatting.gofumpt,
          null_ls.builtins.formatting.golines,
          -- Python
          null_ls.builtins.formatting.black,
          null_ls.builtins.formatting.isort,
        },
      }
    end,
  },
}
