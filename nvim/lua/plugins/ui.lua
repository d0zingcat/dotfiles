-- ui.lua - UI 增强插件配置
-- 包含：lualine, bufferline, neo-tree, noice, snacks(dashboard+notifier), indent-blankline

return {
  -- snacks.nvim - 现代通知 + Dashboard + 其他实用功能
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      dashboard = {
        enabled = true,
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
        preset = {
          header = [[
  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
          keys = {
            { icon = " ", key = "f", desc = "查找文件", action = ":lua Snacks.picker.files()" },
            { icon = " ", key = "g", desc = "全局搜索", action = ":lua Snacks.picker.grep()" },
            { icon = " ", key = "r", desc = "最近文件", action = ":lua Snacks.picker.recent()" },
            { icon = " ", key = "c", desc = "编辑配置", action = ":e $MYVIMRC" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "退出", action = ":qa" },
          },
        },
      },
      notifier = {
        enabled = true,
        timeout = 3000,
        render = "compact",
        style = "compact",
        level = vim.log.levels.INFO,
      },
      quickfile = { enabled = true },
      statuscolumn = { enabled = false },
      words = {
        enabled = true,
        debounce = 100,
        notify_end = false,
        jumplist = true,
      },
      indent = {
        enabled = true,
        animate = { enabled = false },
      },
      picker = { enabled = true },
      input = { enabled = true },
    },
    keys = {
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "清除通知" },
      { "<leader>nh", function() Snacks.notifier.show_history() end, desc = "通知历史" },
      { "<leader>nd", function() Snacks.notifier.hide() end, desc = "关闭所有通知" },
      { "]w", function() Snacks.words.jump(1) end, desc = "下一个引用词" },
      { "[w", function() Snacks.words.jump(-1) end, desc = "上一个引用词" },
      { "<leader>gg", function() Snacks.lazygit() end, desc = "LazyGit" },
      { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "当前文件 Git 历史" },
      { "<leader>gl", function() Snacks.lazygit.log() end, desc = "Git 日志" },
      -- Snacks picker
      { "<leader>ff", function() Snacks.picker.files() end, desc = "查找文件" },
      { "<leader>fr", function() Snacks.picker.recent() end, desc = "最近文件" },
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "查找缓冲区" },
      { "<leader>fg", function() Snacks.picker.grep() end, desc = "全局搜索" },
      { "<leader>fw", function() Snacks.picker.grep_word() end, desc = "搜索当前单词", mode = { "n", "v" } },
      { "<leader>fh", function() Snacks.picker.help() end, desc = "帮助页面" },
      { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "快捷键" },
      { "<leader>fs", function() Snacks.picker.lsp_symbols() end, desc = "文档符号" },
      { "<leader>fS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "工作区符号" },
      { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "诊断" },
    },
    init = function()
      vim.notify = function(msg, level, opts)
        if Snacks and Snacks.notifier then
          Snacks.notifier.notify(msg, level, opts)
        else
          vim.api.nvim_notify(msg or "", level or 0, opts or {})
        end
      end
    end,
  },

  -- 状态栏
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "tokyonight",
        globalstatus = true,
        disabled_filetypes = { statusline = { "dashboard", "snacks_dashboard" } },
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { { "mode", icon = "" } },
        lualine_b = {
          { "branch", icon = "" },
          { "diff", symbols = { added = " ", modified = " ", removed = " " } },
        },
        lualine_c = {
          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            symbols = { error = " ", warn = " ", info = " ", hint = " " },
          },
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { "filename", path = 1, symbols = { modified = "  ", readonly = "  ", unnamed = "  " } },
        },
        lualine_x = {
          {
            function()
              local clients = vim.lsp.get_clients({ bufnr = 0 })
              if #clients == 0 then return "" end
              local names = vim.tbl_map(function(c) return c.name end, clients)
              return " " .. table.concat(names, ", ")
            end,
          },
          { "encoding" },
          { "fileformat" },
          { "filetype" },
        },
        lualine_y = {
          { "progress", padding = { left = 1, right = 1 } },
          { "location", padding = { left = 0, right = 1 } },
        },
        lualine_z = { function() return " " .. os.date("%R") end },
      },
      extensions = { "neo-tree", "lazy", "toggleterm", "mason" },
    },
  },

  -- 缓冲区标签页
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "标记缓冲区" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "关闭未标记缓冲区" },
      { "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "关闭其他缓冲区" },
      { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "关闭右侧缓冲区" },
      { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "关闭左侧缓冲区" },
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "上一个缓冲区" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "下一个缓冲区" },
    },
    opts = {
      options = {
        close_command = function(n) require("mini.bufremove").delete(n, false) end,
        right_mouse_command = function(n) require("mini.bufremove").delete(n, false) end,
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        diagnostics_indicator = function(_, _, diag)
          local ret = (diag.error and " " .. diag.error .. " " or "")
            .. (diag.warning and " " .. diag.warning or "")
          return vim.trim(ret)
        end,
        offsets = {
          { filetype = "neo-tree", text = "文件浏览器", highlight = "Directory", text_align = "left" },
        },
      },
    },
  },

  -- 文件树（侧边栏）
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "文件浏览器" },
      { "<leader>o", "<cmd>Neotree focus<cr>", desc = "聚焦文件浏览器" },
      { "<leader>ge", "<cmd>Neotree float git_status<cr>", desc = "Git 状态" },
    },
    opts = {
      sources = { "filesystem", "buffers", "git_status", "document_symbols" },
      open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf" },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
      window = {
        position = "left",
        width = 30,
        mappings = {
          ["<space>"] = "none",
          ["o"] = "open",
          ["h"] = "close_node",
          ["l"] = "open",
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        git_status = {
          symbols = {
            added = "✚", modified = "", deleted = "✖",
            renamed = "", untracked = "", ignored = "",
            unstaged = "", staged = "", conflict = "",
          },
        },
      },
    },
  },

  -- noice.nvim - 命令行/通知/LSP UI 增强
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
        hover = { enabled = true },
        signature = { enabled = false }, -- blink.cmp 处理签名
        progress = { enabled = true, format_done = "" },
      },
      -- 禁用 vim 命令行的 treesitter 语法高亮（Neovim 0.12 的 vim grammar 移除了 "tab" 节点类型）
      cmdline = {
        format = {
          cmdline = { pattern = "^:", icon = "" },
        },
      },
      routes = {
        {
          -- 屏蔽 treesitter query 兼容性警告（msg_show 和 notify 两种来源）
          filter = {
            any = {
              { event = "msg_show", find = "Query error" },
              { event = "msg_show", find = "Invalid field name" },
              { event = "msg_show", find = "Invalid node type" },
              { event = "notify", find = "Query error" },
              { event = "notify", find = "Invalid field name" },
              { event = "notify", find = "Invalid node type" },
            },
          },
          opts = { skip = true },
        },
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
      },
      presets = {
        bottom_search = true,
        command_palette = false,
        long_message_to_split = true,
        inc_rename = true,
      },
    },
    keys = {
      { "<leader>snl", function() require("noice").cmd("last") end, desc = "最后消息" },
      { "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice 历史" },
      { "<leader>sna", function() require("noice").cmd("all") end, desc = "所有消息" },
    },
  },

  -- 缩进线
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "BufReadPost",
    opts = {
      indent = { char = "│", tab_char = "│" },
      scope = { enabled = false },
      exclude = {
        filetypes = {
          "help", "snacks_dashboard", "neo-tree", "Trouble", "trouble",
          "lazy", "mason", "toggleterm",
        },
      },
    },
  },
}
