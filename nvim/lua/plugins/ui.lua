-- ui.lua - UI 增强插件配置

return {
  -- 状态栏
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "auto",  -- 自动匹配当前主题
        globalstatus = true,  -- 全局状态栏
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          statusline = { "dashboard", "alpha" },
          winbar = { "dashboard", "alpha" },
        },
      },
      sections = {
        lualine_a = { { "mode", icon = "" } },
        lualine_b = { 
          { "branch", icon = "" },
          { 
            "diff", 
            symbols = { added = " ", modified = " ", removed = " " },
            colored = true
          }
        },
        lualine_c = {
          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            symbols = {
              error = " ",
              warn = " ",
              info = " ",
              hint = " ",
            },
          },
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { "filename", path = 1, symbols = { modified = "  ", readonly = "  ", unnamed = "  " } },
        },
        lualine_x = {
          -- Git 文件状态
          {
            function()
              local status = ""
              local ft = vim.bo.filetype
              
              -- 检查 LSP 是否连接
              local clients = vim.lsp.get_active_clients({ bufnr = 0 })
              if #clients > 0 then
                status = status .. " LSP"
              end
              
              return status
            end,
          },
          { "encoding" },
          { "fileformat" },
          { "filetype" },
        },
        lualine_y = {
          { "progress", separator = " ", padding = { left = 1, right = 1 } },
          { "location", padding = { left = 1, right = 1 } },
        },
        lualine_z = {
          function()
            return " " .. os.date("%R")
          end,
        },
      },
      tabline = {},
      extensions = { "neo-tree", "lazy" },
    },
  },
  
  -- 缩进线
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "BufReadPost",
    opts = {
      indent = {
        char = "│",  -- 缩进字符
        tab_char = "│",  -- Tab 缩进字符
      },
      scope = { enabled = false },  -- 禁用范围高亮
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
      },
    },
  },
  
  -- 文件树
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
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "切换文件浏览器" },
      { "<leader>o", "<cmd>Neotree focus<cr>", desc = "聚焦文件浏览器" },
    },
    opts = {
      sources = { "filesystem", "buffers", "git_status", "document_symbols" },
      open_files_do_not_replace_types = { "terminal", "Trouble", "qf", "edgy" },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = true,  -- 显示被过滤的项目
          hide_dotfiles = false,  -- 不隐藏点文件
          hide_gitignored = false,  -- 不隐藏被 gitignore 的文件
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
          with_expanders = true,  -- 启用展开图标
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        git_status = {
          symbols = {
            -- 状态图标
            added     = "✚",  -- 或 "✚"
            modified  = "",  -- 或 ""
            deleted   = "✖",  -- 或 "✖"
            renamed   = "",  -- 或 ""
            untracked = "",
            ignored   = "",
            unstaged  = "",
            staged    = "",
            conflict  = "",
          },
        },
      },
      commands = {
        -- 添加自定义命令，如创建文件时创建路径
        parent_or_close = function(state)
          local node = state.tree:get_node()
          if (node.type == "directory" or node:has_children()) and node:is_expanded() then
            state.commands.toggle_node(state)
          else
            require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
          end
        end,
        child_or_open = function(state)
          local node = state.tree:get_node()
          if node.type == "directory" or node:has_children() then
            if not node:is_expanded() then
              state.commands.toggle_node(state)
            else
              require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
            end
          else
            state.commands.open(state)
          end
        end,
      },
    },
  },
  
  -- 顶部标签页
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "标记/取消标记缓冲区" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "关闭未标记的缓冲区" },
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
        diagnostics = "nvim_lsp",  -- 显示诊断
        always_show_bufferline = false,
        diagnostics_indicator = function(_, _, diag)
          local icons = {
            Error = " ",
            Warn = " ",
            Hint = " ",
            Info = " ",
          }
          local ret = (diag.error and icons.Error .. diag.error .. " " or "")
          .. (diag.warning and icons.Warn .. diag.warning or "")
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "文件浏览器",
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    },
  },
  
  -- 通知系统
  {
    "rcarriga/nvim-notify",
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "清除所有通知",
      },
    },
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
    },
    init = function()
      -- 当 "notify" 可用时，将其替换为 vim.notify
      vim.notify = function(...)
        local loaded, notify = pcall(require, "notify")
        if loaded then
          vim.notify = notify
          return notify(...)
        else
          return vim.api.nvim_notify(...)
        end
      end
    end,
  },
  -- 快捷键提示
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = {
        marks = true,      -- 显示标记
        registers = true,  -- 显示寄存器
        spelling = {
          enabled = true,  -- 启用拼写建议
          suggestions = 20,
        },
        presets = {
          operators = true,    -- 添加操作符帮助
          motions = true,      -- 添加动作帮助
          text_objects = true, -- 添加文本对象帮助
          windows = true,      -- 添加窗口帮助 (meta-w)
          nav = true,          -- 添加导航帮助
          z = true,            -- 添加折叠帮助
          g = true,            -- 添加 g 命令帮助
        },
      },
      icons = {
        breadcrumb = "»", -- 面包屑分隔符
        separator = "➜", -- 键映射前缀和命令之间的分隔符
        group = "+", -- 组图标
      },
      window = {
        border = "rounded",   -- 边框样式
        position = "bottom",  -- 位置
        margin = { 1, 0, 1, 0 }, -- 边距
        padding = { 1, 1, 1, 1 }, -- 内边距
      },
      layout = {
        height = { min = 3, max = 25 },  -- 最小和最大高度
        width = { min = 20, max = 50 },  -- 最小和最大宽度
        spacing = 3,  -- 间距
        align = "center",  -- 对齐方式
      },
      ignore_missing = false,  -- 不忽略缺少的键映射
      hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "^:", "^ ", "^call ", "^lua " },  -- 隐藏的命令前缀
      show_help = true,  -- 显示帮助信息
      triggers = "auto",  -- 触发自动显示
      triggers_nowait = {  -- 不等待这些前缀的键映射
        -- 字符表示操作符等待模式
        "`",
        "'",
        "g`",
        "g'",
        '"',
        "<c-r>",
        "z=",
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
    end,
  },
} 