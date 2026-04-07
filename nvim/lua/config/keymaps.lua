-- keymaps.lua - 键位映射配置

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- 插入模式退出
map("i", "jk", "<ESC>", opts)

-- 保存和退出
map("n", "<leader>w", "<cmd>w<cr>", { desc = "保存文件" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "退出" })
map("n", "<leader>Q", "<cmd>qa<cr>", { desc = "退出全部" })

-- 清除搜索高亮
map("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "清除搜索高亮" })

-- 缩进保持选中
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- 上下移动选中文本
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "向下移动选中" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "向上移动选中" })

-- 粘贴不覆盖寄存器
map("x", "p", [["_dP]], { desc = "粘贴不覆盖寄存器" })

-- 删除到黑洞寄存器
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "删除到黑洞寄存器" })

-- 快速移动（保持居中）
map("n", "J", "mzJ`z", { desc = "连接行" })
map("n", "<C-d>", "<C-d>zz", { desc = "向下翻页居中" })
map("n", "<C-u>", "<C-u>zz", { desc = "向上翻页居中" })
map("n", "n", "nzzzv", { desc = "下一个结果居中" })
map("n", "N", "Nzzzv", { desc = "上一个结果居中" })

-- 窗口导航
map("n", "<C-h>", "<C-w>h", { desc = "左窗口" })
map("n", "<C-j>", "<C-w>j", { desc = "下窗口" })
map("n", "<C-k>", "<C-w>k", { desc = "上窗口" })
map("n", "<C-l>", "<C-w>l", { desc = "右窗口" })

-- 窗口分割
map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "垂直分割" })
map("n", "<leader>sh", "<cmd>split<cr>", { desc = "水平分割" })
map("n", "<leader>se", "<C-w>=", { desc = "均分窗口" })
map("n", "<leader>sx", "<cmd>close<cr>", { desc = "关闭窗口" })

-- 调整窗口大小
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "增加高度" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "减少高度" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "减少宽度" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "增加宽度" })

-- 终端模式
map("t", "<Esc>", "<C-\\><C-n>", { desc = "退出终端模式" })
map("t", "jk", "<C-\\><C-n>", { desc = "退出终端模式" })
map("t", "<C-h>", "<C-\\><C-n><C-w>h", opts)
map("t", "<C-j>", "<C-\\><C-n><C-w>j", opts)
map("t", "<C-k>", "<C-\\><C-n><C-w>k", opts)
map("t", "<C-l>", "<C-\\><C-n><C-w>l", opts)

-- 实用工具
map("n", "<leader>r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "替换当前单词" })
map("n", "<leader>x", "<cmd>!chmod +x %<CR>", { desc = "使文件可执行", silent = true })

-- 命令行历史
map("c", "<C-j>", "<Down>", { desc = "下一条命令" })
map("c", "<C-k>", "<Up>", { desc = "上一条命令" })

-- 更好的搜索
map("n", "g/", "/\\<\\><Left><Left>", { desc = "搜索单词" })
