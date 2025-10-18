-- treesitter.lua - 语法高亮与代码结构
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = { "go", "python", "lua", "json", "yaml", "markdown" },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
}
