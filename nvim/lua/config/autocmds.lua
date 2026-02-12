-- autocmds.lua - 自动命令配置

-- 创建自动命令组
local augroup = vim.api.nvim_create_augroup("MyCustomGroup", { clear = true })

-- 自动设置光标行
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

-- 自动切换工作目录
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = "*",
  group = augroup,
  desc = "自动切换到文件所在目录",
  callback = function()
    local buftype = vim.bo.buftype
    if buftype ~= "terminal" and buftype ~= "nofile" and buftype ~= "prompt" then
      vim.cmd("silent! lcd %:p:h")
    end
  end,
})

-- 自动恢复光标位置
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

-- 自动关闭某些窗口的 q 键
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "qf",
    "help",
    "man",
    "notify",
    "lspinfo",
    "startuptime",
    "tsplayground",
    "spectre_panel",
    "PlenaryTestPopup",
  },
  group = augroup,
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- 在保存时自动删除行尾空白字符
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  group = augroup,
  desc = "删除行尾空白字符",
  callback = function()
    -- 保存当前位置
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    -- 保存搜索寄存器
    local search = vim.fn.getreg("/")
    
    -- 替换所有行尾空白字符
    vim.cmd([[%s/\s\+$//e]])
    
    -- 恢复搜索寄存器
    vim.fn.setreg("/", search)
    -- 恢复光标位置
    vim.api.nvim_win_set_cursor(0, cursor_pos)
  end,
})

-- 自动设置文件类型的选项
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  group = augroup,
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.textwidth = 88  -- 符合 black 格式化
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
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json", "html", "css", "yaml", "markdown" },
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

-- 为新文件创建模板
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.py",
  group = augroup,
  callback = function()
    local lines = {
      "#!/usr/bin/env python3",
      "# -*- coding: utf-8 -*-",
      "\"\"\"",
      "Description: ",
      "\"\"\"",
      "",
      "",
      "def main():",
      "    pass",
      "",
      "",
      "if __name__ == \"__main__\":",
      "    main()",
      "",
    }
    vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
    vim.api.nvim_win_set_cursor(0, { 4, 13 })
  end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.go",
  group = augroup,
  callback = function()
    local package_name = vim.fn.fnamemodify(vim.fn.expand("%:p:h:t"), ":r")
    
    local lines = {
      "package " .. package_name,
      "",
      "import (",
      "\t\"fmt\"",
      ")",
      "",
      "// TODO: Add description here",
      "",
      "",
    }
    vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
    vim.api.nvim_win_set_cursor(0, { 7, 27 })
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

-- 当 checktime 检测到文件已更改时通知
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  group = augroup,
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded!", vim.log.levels.WARN)
  end,
}) 