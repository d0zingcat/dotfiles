-- lspconfig.lua - LSP 配置
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      -- Go
      lspconfig.gopls.setup({ capabilities = capabilities })
      -- Python
      lspconfig.pyright.setup({ capabilities = capabilities })
    end,
  },
}
