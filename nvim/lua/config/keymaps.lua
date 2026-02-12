-- keymaps.lua - 键位映射配置

-- 设置局部变量
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

--[[
模式说明:
  n: 普通模式
  i: 插入模式
  v: 可视模式
  x: 可视块模式
  t: 终端模式
  c: 命令行模式
]]--

-----------------
-- 基础键位映射 --
-----------------

-- 使用 jk 从插入模式返回普通模式
map("i", "jk", "<ESC>", opts)

-- 保存和退出
map("n", "<leader>w", "<cmd>w<cr>", { desc = "保存文件" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "退出" })
map("n", "<leader>Q", "<cmd>qa<cr>", { desc = "退出全部" })

-- 清除搜索高亮
map("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "清除搜索高亮" })

-- 更好的缩进
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- 上下移动选中的文本
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "向下移动选中文本" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "向上移动选中文本" })

-- 保持复制内容在粘贴后
map("x", "p", [["_dP]], { desc = "粘贴不覆盖寄存器" })

-- 删除到黑洞寄存器
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "删除到黑洞寄存器" })

-- 快速移动
map("n", "J", "mzJ`z", { desc = "连接行保持光标位置" })
map("n", "<C-d>", "<C-d>zz", { desc = "向下移动保持光标居中" })
map("n", "<C-u>", "<C-u>zz", { desc = "向上移动保持光标居中" })
map("n", "n", "nzzzv", { desc = "下一个搜索结果并居中" })
map("n", "N", "Nzzzv", { desc = "上一个搜索结果并居中" })

-------------------------
-- 窗口和缓冲区管理 --
-------------------------

-- 窗口间导航
map("n", "<C-h>", "<C-w>h", { desc = "移动到左窗口" })
map("n", "<C-j>", "<C-w>j", { desc = "移动到下窗口" })
map("n", "<C-k>", "<C-w>k", { desc = "移动到上窗口" })
map("n", "<C-l>", "<C-w>l", { desc = "移动到右窗口" })

-- 缓冲区导航
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "上一个缓冲区" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "下一个缓冲区" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "关闭当前缓冲区" })
map("n", "<leader>ba", "<cmd>bufdo bd<cr>", { desc = "关闭所有缓冲区" })

-- 窗口分割
map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "垂直分割" })
map("n", "<leader>sh", "<cmd>split<cr>", { desc = "水平分割" })
map("n", "<leader>se", "<C-w>=", { desc = "使所有窗口等宽" })
map("n", "<leader>sx", "<cmd>close<cr>", { desc = "关闭当前窗口" })

-- 调整窗口大小
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "增加窗口高度" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "减小窗口高度" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "减小窗口宽度" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "增加窗口宽度" })

-------------------------
-- 终端模式映射 --
-------------------------

-- 退出终端模式
map("t", "<Esc>", "<C-\\><C-n>", { desc = "退出终端模式" })
map("t", "jk", "<C-\\><C-n>", { desc = "退出终端模式" })

-- 终端窗口导航
map("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "终端模式下向左移动" })
map("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "终端模式下向下移动" })
map("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "终端模式下向上移动" })
map("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "终端模式下向右移动" })

-------------------------
-- 实用功能 --
-------------------------

-- 全文快速替换当前单词
map("n", "<leader>r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "替换当前单词" })

-- 使当前文件可执行
map("n", "<leader>x", "<cmd>!chmod +x %<CR>", { desc = "使当前文件可执行", silent = true })

-- 打开一个新的终端
map("n", "<leader>t", "<cmd>terminal<cr>", { desc = "打开终端" })

-- 快速编辑配置文件
map("n", "<leader>ev", "<cmd>e $MYVIMRC<cr>", { desc = "编辑init.lua" })
map("n", "<leader>sv", "<cmd>source $MYVIMRC<cr>", { desc = "重新加载配置" })

-- 更简单的命令行历史导航
map("c", "<C-j>", "<Down>", { desc = "下一个命令历史" })
map("c", "<C-k>", "<Up>", { desc = "上一个命令历史" })

-- 更好的搜索
map("n", "g/", "/\\<\\><Left><Left>", { desc = "搜索单词" }) 