-- lazy.lua - lazy.nvim 插件管理器配置

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- 配置 lazy.nvim
require("lazy").setup({
  -- 插件列表
  spec = {
    { import = "plugins" },
    { import = "plugins.lang" },
  },
  
  -- 默认配置
  defaults = {
    lazy = false,           -- 默认不延迟加载
    version = false,        -- 使用最新版本
  },
  
  -- 安装配置
  install = {
    colorscheme = { "tokyonight", "habamax" },  -- 安装时使用的主题
    missing = true,         -- 自动安装缺失的插件
  },
  
  -- 性能配置
  performance = {
    rtp = {
      -- 禁用一些内置插件
      disabled_plugins = {
        "gzip",             -- 不需要在编辑器内处理 gzip 文件
        "matchit",          -- 使用 treesitter 代替
        "matchparen",       -- 使用 treesitter 代替
        "netrwPlugin",      -- 使用 nvim-tree 代替
        "tarPlugin",        -- 不需要在编辑器内处理 tar 文件
        "tohtml",           -- 不需要转换为 HTML
        "tutor",            -- 不需要内置教程
        "zipPlugin",        -- 不需要在编辑器内处理 zip 文件
      },
    },
  },
  
  -- UI 配置
  ui = {
    -- 自定义图标
    icons = {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🔑",
      plugin = "🔌",
      runtime = "💻",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤 ",
    },
    size = { width = 0.8, height = 0.8 },  -- 窗口大小
    wrap = true,                           -- 自动换行
    border = "rounded",                    -- 边框样式
  },
  
  -- 检查更新配置
  checker = {
    enabled = true,         -- 启用自动检查更新
    frequency = 3600,       -- 检查频率（秒）
    notify = false,         -- 禁用更新通知
  },
  
  -- 更新配置
  change_detection = {
    enabled = true,         -- 启用自动重载
    notify = false,         -- 禁用更改通知
  },
}) 