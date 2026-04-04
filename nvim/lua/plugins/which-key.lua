return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- 基础配置
    preset = "helix", -- 使用 helix 预设，更现代的样式

    -- 延迟配置
    delay = 500, -- 显示 which-key 的延迟时间（毫秒）

    -- 过滤配置
    filter = function(mapping)
      -- 只显示有描述的映射
      return mapping.desc and mapping.desc ~= ""
    end,

    -- 触发配置
    triggers = {
      { "<auto>", mode = "nxso" },
    },

    -- 窗口配置
    win = {
      no_overlap = true,
      padding = { 1, 2 }, -- 上下, 左右
      title = true,
      title_pos = "center",
      zindex = 1000,
      bo = {},
      wo = {
        winblend = 10,
      },
    },

    -- 布局配置
    layout = {
      width = { min = 20 }, -- 最小宽度
      spacing = 3, -- 列间距
      align = "left", -- 对齐方式
    },

    -- 图标配置
    icons = {
      breadcrumb = "»", -- 面包屑符号
      separator = "➜", -- 分隔符
      group = "+", -- 分组符号
      ellipsis = "…",
      keys = {
        Space = "<space>",
        Tab = "<tab>",
        Return = "<cr>",
        Escape = "<esc>",
        Backspace = "<bs>",
        Delete = "<del>",
        Insert = "<ins>",
        Home = "<home>",
        End = "<end>",
        PageUp = "<pageup>",
        PageDown = "<pagedown>",
        ScrollLock = "<scrolllock>",
        NumLock = "<numlock>",
        CapsLock = "<capslock>",
        Left = "<left>",
        Right = "<right>",
        Up = "<up>",
        Down = "<down>",
        F1 = "<f1>",
        F2 = "<f2>",
        F3 = "<f3>",
        F4 = "<f4>",
        F5 = "<f5>",
        F6 = "<f6>",
        F7 = "<f7>",
        F8 = "<f8>",
        F9 = "<f9>",
        F10 = "<f10>",
        F11 = "<f11>",
        F12 = "<f12>",
        Plug = "<plug>",
        Action = "<action>",
        Alt = "<a-",
        Control = "<c-",
        Meta = "<m-",
        Shift = "<s-",
        Super = "<d-",
        Leader = "<leader>",
        LocalLeader = "<localleader>",
      },
    },

    -- 排序配置
    sort = { "alphanum" },

    -- 替换配置
    replace = {
      desc = {
        { "<Plug>%(?(.*)%)?", "%1" },
        { "^[cgls]%[?(.*)%]?$", "%1" },
        { "^ lua%.patterns%.(.+)$", "Pattern: %1" },
        { "^ lua%.snippets%.(.+)$", "Snippet: %1" },
        { "^ which%-key%.(.+)$", "WK: %1" },
        { "^.*%.(.+)$", "%1" },
      },
    },

    -- 通知配置
    notify = true,

    -- 调试配置
    debug = false,

    -- 自动注册键组
    spec = {},
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    -- 注册键组
    wk.add({
      -- 文件操作
      { "<leader>f", group = "文件/查找", icon = { icon = "📁", color = "blue" } },

      -- Git 操作
      { "<leader>g", group = "Git", icon = { icon = "🌿", color = "green" } },

      -- LSP/Code 操作
      { "<leader>c", group = "代码/LSP", icon = { icon = "💻", color = "cyan" } },

      -- 诊断
      { "<leader>x", group = "诊断", icon = { icon = "🚨", color = "red" } },

      -- 搜索
      { "<leader>s", group = "搜索", icon = { icon = "🔍", color = "yellow" } },

      -- 终端
      { "<leader>t", group = "终端", icon = { icon = "🖥️", color = "purple" } },

      -- 缓冲区
      { "<leader>b", group = "缓冲区", icon = { icon = "📋", color = "blue" } },

      -- 通知
      { "<leader>u", group = "UI/通知", icon = { icon = "🎨", color = "purple" } },

      -- AI 助手
      { "<leader>a", group = "AI 助手", icon = { icon = "🤖", color = "cyan" } },

      -- Python
      { "<leader>p", group = "Python", icon = { icon = "🐍", color = "green" } },

      -- 会话
      { "<leader>q", group = "会话/退出", icon = { icon = "🚪", color = "red" } },

      -- 窗口
      { "<leader>w", group = "窗口", icon = { icon = "🪟", color = "blue" } },
    })
  end,
}
