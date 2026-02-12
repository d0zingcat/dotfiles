-- options.lua - 基本编辑器选项设置

local opt = vim.opt
local g = vim.g

-- UI设置
opt.termguicolors = true        -- 使用终端真彩色
opt.number = true               -- 显示行号
opt.relativenumber = true       -- 相对行号
opt.cursorline = true           -- 高亮当前行
opt.cursorcolumn = true         -- 高亮当前列
opt.signcolumn = "auto:1"       -- 显示标记列
opt.showmatch = true            -- 高亮匹配的括号
opt.showmode = false            -- 不显示模式，由状态栏插件替代
opt.laststatus = 3              -- 全局状态栏
opt.cmdheight = 1               -- 命令行高度
opt.scrolloff = 10              -- 光标上下保留的行数
opt.sidescrolloff = 10          -- 光标左右保留的列数
opt.wrap = false                -- 不自动换行
opt.linebreak = true            -- 如果wrap开启，在单词边界处换行
opt.list = true                 -- 显示不可见字符
opt.listchars = {               -- 设置不可见字符的显示方式
  tab = "» ",
  trail = "·",
  extends = "›",
  precedes = "‹",
  nbsp = "␣",
  eol = "↴"
}
opt.fillchars:append({          -- 分隔符符号设置
  vert = "│",                   -- 窗口分隔符
  fold = "⠀",                   -- 折叠
  eob = " ",                    -- 缓冲区末尾的空行
  diff = "╱",                   -- 差异模式的删除行
})

-- 编辑设置
opt.tabstop = 4                 -- Tab宽度
opt.softtabstop = 4             -- 编辑时的Tab宽度
opt.shiftwidth = 4              -- 缩进宽度
opt.expandtab = true            -- 使用空格替代Tab
opt.smartindent = true          -- 智能缩进
opt.autoindent = true           -- 自动缩进
opt.cindent = true              -- C语言缩进规则
opt.textwidth = 120             -- 文本宽度
opt.formatoptions = "jcroqlnt"  -- 格式化选项
opt.foldenable = false          -- 默认不折叠
opt.foldmethod = "expr"         -- 使用表达式进行折叠
opt.foldexpr = "nvim_treesitter#foldexpr()" -- 使用treesitter进行折叠

-- 搜索设置
opt.ignorecase = true           -- 搜索忽略大小写
opt.smartcase = true            -- 如果搜索包含大写字母，则区分大小写
opt.hlsearch = true             -- 高亮搜索结果
opt.incsearch = true            -- 增量搜索

-- 性能设置
opt.hidden = true               -- 允许切换未保存的缓冲区
opt.history = 500               -- 历史记录数
opt.updatetime = 100            -- 更新时间（ms）
opt.timeout = true              -- 启用超时
opt.timeoutlen = 300            -- 键映射超时时间（ms）
opt.ttimeoutlen = 10            -- 键码超时时间（ms）
opt.synmaxcol = 240             -- 最大语法分析列数

-- 文件设置
opt.fileencoding = "utf-8"      -- 文件编码
opt.backup = false              -- 不创建备份文件
opt.swapfile = false            -- 不创建交换文件
opt.undofile = true             -- 启用持久撤销
opt.undodir = vim.fn.stdpath("data") .. "/undo" -- 撤销文件目录

-- 鼠标设置
opt.mouse = "a"                 -- 启用鼠标

-- 分隔符设置
opt.splitbelow = true           -- 新的水平分割窗口在下面
opt.splitright = true           -- 新的垂直分割窗口在右边

-- 通用设置
opt.clipboard = "unnamedplus"   -- 使用系统剪贴板
opt.completeopt = "menu,menuone,noselect" -- 补全选项
opt.pumheight = 10              -- 弹出菜单高度
opt.confirm = true              -- 显示确认对话框
opt.autoread = true             -- 自动重新加载文件

-- 加载 .nvimrc, .exrc 等本地配置
opt.exrc = true                 -- 启用 .exrc
opt.secure = true               -- 限制本地配置中的命令 