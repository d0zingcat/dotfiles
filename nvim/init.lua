-- 设置 mapleader 必须在加载插件前
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 加载基础配置
require("config.options")   -- 基本设置
require("config.keymaps")   -- 键位映射
require("config.autocmds")  -- 自动命令

-- 加载插件管理器
require("config.lazy") 