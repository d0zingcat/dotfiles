-- utils.lua - 实用工具插件配置

return {
  -- 启动界面
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    opts = function()
      local dashboard = require("alpha.themes.dashboard")
      local logo = [[
      ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
      ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
      ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
      ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
      ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
      ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
      ]]

      dashboard.section.header.val = vim.split(logo, "\n")
      dashboard.section.buttons.val = {
        dashboard.button("f", "  查找文件", ":Telescope find_files <CR>"),
        dashboard.button("e", "  新文件", ":ene <BAR> startinsert <CR>"),
        dashboard.button("r", "  最近文件", ":Telescope oldfiles <CR>"),
        dashboard.button("g", "  查找文本", ":Telescope live_grep <CR>"),
        dashboard.button("c", "  配置", ":e $MYVIMRC <CR>"),
        dashboard.button("l", "  懒加载插件", ":Lazy<CR>"),
        dashboard.button("q", "  退出", ":qa<CR>"),
      }
      
      dashboard.section.footer.val = "Neovim 配置 - 专注于 Python 和 Go 开发"
      
      dashboard.section.header.opts.hl = "Type"
      dashboard.section.buttons.opts.hl = "Keyword"
      dashboard.section.footer.opts.hl = "Comment"
      
      dashboard.opts.opts.noautocmd = true
      return dashboard
    end,
    config = function(_, dashboard)
      require("alpha").setup(dashboard.opts)
      
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          local version = "   v" .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch
          local plugins = "   " .. stats.count .. " 个插件加载完成，用时 " .. ms .. "ms"
          local footer = version .. "\n" .. plugins
          
          pcall(function()
            local alpha = require("alpha")
            local dashboard = alpha.themes.dashboard
            dashboard.section.footer.val = footer
            alpha.redraw()
          end)
        end,
      })
    end,
  },
  
  -- 查找器增强
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      search = {
        multi_window = false, -- 只在当前窗口搜索
        wrap = true,          -- 循环搜索
      },
      modes = {
        char = {
          enabled = true,
          keys = { "f", "F", "t", "T", ";", "," },
        },
      },
    },
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "闪烁跳转",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "闪烁 Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "远程闪烁",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter 搜索",
      },
    },
  },
  
  -- 项目管理
  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup({
        patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "pyproject.toml", "go.mod" },
        detection_methods = { "pattern", "lsp" },
        show_hidden = true,
        silent_chdir = true,
        scope_chdir = "global",
      })
      
      require("telescope").load_extension("projects")
    end,
    keys = {
      { "<leader>fp", "<cmd>Telescope projects<cr>", desc = "项目" },
    },
  },
  
  -- 文件浏览器增强
  {
    "stevearc/oil.nvim",
    opts = {
      default_file_explorer = true,
      columns = {
        "icon",
        "permissions",
        "size",
        "mtime",
      },
      buf_options = {
        buflisted = false,
        bufhidden = "hide",
      },
      win_options = {
        wrap = false,
        signcolumn = "no",
        cursorcolumn = false,
        foldcolumn = "0",
        spell = false,
        list = false,
        conceallevel = 3,
        concealcursor = "n",
      },
      delete_to_trash = true,
      skip_confirm_for_simple_edits = false,
      prompt_save_on_select_new_entry = true,
      cleanup_delay_ms = 2000,
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-s>"] = "actions.select_vsplit",
        ["<C-h>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["<C-l>"] = "actions.refresh",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",
        ["g\\"] = "actions.toggle_trash",
      },
      use_default_keymaps = true,
      view_options = {
        show_hidden = true,
        is_hidden_file = function(name, bufnr)
          return vim.startswith(name, ".")
        end,
        is_always_hidden = function(name, bufnr)
          return false
        end,
      },
      float = {
        padding = 2,
        max_width = 0,
        max_height = 0,
        border = "rounded",
        win_options = {
          winblend = 0,
        },
      },
      preview = {
        max_width = 0.9,
        min_width = { 40, 0.4 },
        width = nil,
        max_height = 0.9,
        min_height = { 5, 0.1 },
        height = nil,
        border = "rounded",
        win_options = {
          winblend = 0,
        },
      },
      progress = {
        max_width = 0.9,
        min_width = { 40, 0.4 },
        width = nil,
        max_height = 0.9,
        min_height = { 5, 0.1 },
        height = nil,
        border = "rounded",
        minimized_border = "none",
        win_options = {
          winblend = 0,
        },
      },
    },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "打开父目录" },
      { "<leader>fo", "<cmd>Oil<cr>", desc = "打开文件浏览器" },
    },
  },
  
  -- 自动调整窗口大小
  {
    "anuvyklack/windows.nvim",
    event = "WinNew",
    dependencies = {
      { "anuvyklack/middleclass" },
      { "anuvyklack/animation.nvim", enabled = true },
    },
    keys = {
      { "<leader>wm", "<cmd>WindowsMaximize<cr>", desc = "最大化窗口" },
      { "<leader>w=", "<cmd>WindowsEqualize<cr>", desc = "均分窗口" },
    },
    config = function()
      vim.o.winwidth = 10
      vim.o.winminwidth = 10
      vim.o.equalalways = false
      require("windows").setup({
        animation = { enable = true, duration = 150 },
        autowidth = { enable = true },
      })
    end,
  },
  
  -- 会话管理
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
      dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
      options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" },
      pre_save = nil,
    },
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "恢复上次会话" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "恢复最后会话" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "不保存当前会话" },
    },
  },
  
  -- 键位映射管理
  {
    "mrjones2014/legendary.nvim",
    keys = {
      { "<leader>k", "<cmd>Legendary<cr>", desc = "键位映射查找器" },
    },
    opts = {
      include_builtin = true,
      include_legendary_cmds = true,
      extensions = {
        which_key = { auto_register = true },
        smart_splits = { auto_register = true },
      },
    },
  },
  
  -- AI 补全集成
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = {
          enabled = true,
          auto_refresh = true,
          keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gr",
            open = "<M-CR>"
          },
          layout = {
            position = "bottom", -- | top | left | right
            ratio = 0.4
          },
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = "<M-l>",
            accept_word = "<M-w>",
            accept_line = "<M-j>",
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        filetypes = {
          yaml = false,
          markdown = false,
          help = false,
          gitcommit = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,
        },
        copilot_node_command = 'node', -- Node.js 版本
        server_opts_overrides = {},
      })
    end,
  },
} 