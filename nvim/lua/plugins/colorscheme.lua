-- colorscheme.lua - 主题配置

return {
  -- 主题：Tokyo Night
  {
    "folke/tokyonight.nvim",
    lazy = false,  -- 不延迟加载主题
    priority = 1000,  -- 确保先加载主题
    config = function()
      require("tokyonight").setup({
        style = "night",  -- 可选值："storm", "moon", "night", "day"
        transparent = false,  -- 启用背景透明
        terminal_colors = true,  -- 设置终端颜色
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
          sidebars = "dark",
          floats = "dark",
        },
        sidebars = { "qf", "help", "terminal", "packer", "NvimTree", "Trouble" },
        dim_inactive = false,  -- 非活动窗口变暗
        lualine_bold = true,  -- 在状态栏中使用粗体
        
        on_highlights = function(hl, c)
          -- 自定义高亮组
          hl.CursorLineNr = { fg = c.orange, bold = true }
          hl.LineNr = { fg = c.orange, bold = false }
          hl.LineNrAbove = { fg = c.fg_gutter }
          hl.LineNrBelow = { fg = c.fg_gutter }
          
          -- 浮动窗口
          hl.NormalFloat = { bg = c.bg_dark }
          hl.FloatBorder = { bg = c.bg_dark, fg = c.blue }
        end,
      })
      
      -- 加载主题
      vim.cmd.colorscheme("tokyonight")
    end
  },
  
  -- 替代主题：Catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,  -- 懒加载此主题
    opts = {
      flavour = "mocha",  -- 风格: latte, frappe, macchiato, mocha
      term_colors = true,
      transparent_background = false,
      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
      },
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        mason = true,
        telescope = {
          enabled = true,
          style = "nvchad",
        },
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
          },
        },
      },
    },
  },
  
  -- 图标支持
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },
} 