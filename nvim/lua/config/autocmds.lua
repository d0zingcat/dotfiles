-- autocmds.lua - 自动命令配置

local augroup = vim.api.nvim_create_augroup("MyCustomGroup", { clear = true })

-- 插入模式进出切换光标行高亮
vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
  pattern = "*",
  group = augroup,
  callback = function()
    if vim.bo.buftype ~= "terminal" then
      vim.opt_local.cursorline = true
    end
  end,
})

vim.api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
  pattern = "*",
  group = augroup,
  callback = function()
    if vim.bo.buftype ~= "terminal" then
      vim.opt_local.cursorline = false
    end
  end,
})

-- 高亮复制文本
vim.api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  group = augroup,
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- 恢复光标位置
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  desc = "恢复光标位置",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- 特定文件类型用 q 关闭
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "qf", "help", "man", "notify", "lspinfo", "startuptime",
    "tsplayground", "spectre_panel", "PlenaryTestPopup",
    "checkhealth", "neotest-output", "neotest-summary",
  },
  group = augroup,
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- 保存时删除行尾空白（markdown 使用尾部空格表示换行，需跳过）
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  group = augroup,
  desc = "删除行尾空白",
  callback = function()
    local ft = vim.bo.filetype
    if ft == "markdown" or ft == "text" or ft == "diff" then return end
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local search = vim.fn.getreg("/")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setreg("/", search)
    vim.api.nvim_win_set_cursor(0, cursor_pos)
  end,
})

-- 在外部更改时自动重新加载文件
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  group = augroup,
  callback = function()
    if vim.fn.mode() ~= "c" and not vim.bo.readonly then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  group = augroup,
  callback = function()
    vim.notify("文件已被外部修改，缓冲区已重新加载", vim.log.levels.WARN)
  end,
})

-- ========== 语言专用设置 ==========

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  group = augroup,
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.textwidth = 88
    vim.opt_local.colorcolumn = "88"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  group = augroup,
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  group = augroup,
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.textwidth = 100
    vim.opt_local.colorcolumn = "100"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json", "jsonc", "html", "css", "scss", "yaml", "markdown" },
  group = augroup,
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "make",
  group = augroup,
  callback = function()
    vim.opt_local.expandtab = false
  end,
})
