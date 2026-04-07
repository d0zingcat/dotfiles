-- colorscheme.lua - 主题配置

return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = "dark",
        floats = "dark",
      },
      sidebars = { "qf", "help", "terminal", "Trouble", "neo-tree" },
      dim_inactive = false,
      lualine_bold = true,
      on_highlights = function(hl, c)
        hl.CursorLineNr = { fg = c.orange, bold = true }
        hl.LineNr = { fg = c.orange, bold = false }
        hl.LineNrAbove = { fg = c.fg_gutter }
        hl.LineNrBelow = { fg = c.fg_gutter }
        hl.NormalFloat = { bg = c.bg_dark }
        hl.FloatBorder = { bg = c.bg_dark, fg = c.blue }
      end,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    opts = {
      flavour = "mocha",
      term_colors = true,
      transparent_background = false,
      integrations = {
        cmp = true,
        gitsigns = true,
        treesitter = true,
        mason = true,
        telescope = { enabled = true },
        native_lsp = { enabled = true },
        blink_cmp = true,
      },
    },
  },

  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },
}
 