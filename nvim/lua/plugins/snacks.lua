-- snacks.lua - folke's modern utility library
-- Provides: notifications, bigfile handling, quickfile, statuscolumn, word highlighting

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      -- Bigfile optimization
      bigfile = {
        enabled = true,
        notify = true,
        line_length = 1000,
      },

      -- Notifications (replaces nvim-notify)
      notifier = {
        enabled = true,
        timeout = 3000,
        history = true,
        render = "compact",
        level = vim.log.levels.INFO,
      },

      -- Quick file navigation
      quickfile = {
        enabled = true,
        exclude = { "gitcommit", "gitrebase" },
      },

      -- Enhanced statuscolumn
      statuscolumn = {
        enabled = true,
        left = { "mark", "sign" },
        right = { "fold", "git" },
        folds = {
          open = true,
          git_hl = false,
        },
      },

      -- Word highlighting and jumping
      words = {
        enabled = true,
        debounce = 100,
        notify_end = false,
        jumplist = true,
        mappings = {
          ["]w"] = "next",
          ["[w"] = "prev",
        },
      },
    },
    keys = {
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
      { "<leader>q", function() Snacks.quickfile() end, desc = "Quick File" },
      { "]w", function() Snacks.words.jump() end, desc = "Next Word Reference" },
      { "[w", function() Snacks.words.jump(-1) end, desc = "Prev Word Reference" },
    },
    init = function()
      -- Override vim.notify
      vim.notify = function(msg, level, opts)
        Snacks.notifier.notify(msg, level, opts)
      end
    end,
  },
}
