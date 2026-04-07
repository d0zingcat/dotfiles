-- treesitter.lua - 语法高亮与代码结构

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile", "BufWritePre", "VeryLazy" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    opts = {
      ensure_installed = {
        -- "comment" 已在新版 nvim-treesitter 中弃用，避免 query 校验错误
        "bash", "c", "cmake", "css", "diff", "dockerfile",
        "git_config", "git_rebase", "gitcommit", "gitignore",
        "go", "gomod", "gosum", "gowork",
        "html", "javascript", "jsdoc", "json", "jsonc",
        "lua", "luadoc", "luap", "make", "markdown", "markdown_inline",
        "python", "regex", "rst", "rust", "sql", "toml",
        "tsx", "typescript", "vim", "vimdoc", "xml", "yaml",
      },
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
            ["ab"] = "@block.outer",
            ["ib"] = "@block.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
          },
          goto_next_end = {
            ["]F"] = "@function.outer",
            ["]C"] = "@class.outer",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
          },
          goto_previous_end = {
            ["[F"] = "@function.outer",
            ["[C"] = "@class.outer",
          },
        },
      },
    },
    config = function(_, opts)
      -- nvim-treesitter v1+ 重构后移除了 configs 子模块，需要兼容两种 API
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if ok then
        configs.setup(opts)
      else
        -- 新版 API：直接调用顶层模块
        require("nvim-treesitter").setup(opts)
      end
    end,
  },
}
