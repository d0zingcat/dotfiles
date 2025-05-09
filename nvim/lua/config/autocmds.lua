-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.cmd('filetype plugin indent on')

-- Create a group for our autocommands
local augroup = vim.api.nvim_create_augroup("CustomSettings", { clear = true })

-- FileType autocommands
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  group = augroup,
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.textwidth = 120
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  group = augroup,
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.textwidth = 120
    vim.opt_local.expandtab = false
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json", "jsonnet" },
  group = augroup,
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "yaml",
  group = augroup,
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.textwidth = 0
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "gotmpl",
  group = augroup,
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.textwidth = 0
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "php",
  group = augroup,
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.textwidth = 120
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "html", "htmldjango", "xhtml", "haml" },
  group = augroup,
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.textwidth = 0
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "ruby",
  group = augroup,
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.textwidth = 120
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "less", "sass", "scss", "css" },
  group = augroup,
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.textwidth = 120
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "javascript.jsx", "javascriptreact", "typescript", "typescriptreact" },
  group = augroup,
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "NvimTree",
  group = augroup,
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.textwidth = 0
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "make",
  group = augroup,
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.shiftwidth = 8
    vim.opt_local.softtabstop = 0
  end,
})

-- File pattern autocommands
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.proto",
  group = augroup,
  command = "setfiletype proto",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "proto",
  group = augroup,
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})