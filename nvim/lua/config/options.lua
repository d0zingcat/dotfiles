-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt
local o = vim.o
local g = vim.g

g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
o.termguicolors = true

g.mapleader = ' '       -- Make sure to set `mapleader` before lazy so your mappings are correct
g.maplocalleader = '\\' -- Same for `maplocalleader`

o.encoding = 'utf-8'
o.fileencoding = 'utf-8'
o.fencs = 'utf-8,ucs-bom,shift-jis,gb18030,gbk,gb2312,cp936'
o.hidden = true
o.wildmenu = true
o.hlsearch = true
o.incsearch = true
o.matchtime = 1
o.showmatch = true
o.updatetime = 100
o.ignorecase = true
o.smarttab = true
o.expandtab = true
o.laststatus = 2
o.showcmd = true
o.ruler = true
o.history = 300
o.backup = false
o.swapfile = false
o.foldenable = false
o.autoread = true
o.autowrite = true
o.mouse = 'a'

o.number = true
o.cursorline = true
o.relativenumber = true
o.cursorcolumn = true
o.signcolumn = 'auto:1'
-- o.cmdheight = 0
opt.list = true
opt.listchars:append('eol:↴')
opt.fillchars:append { diff = '╱' }

o.textwidth = 120
o.smartindent = true
o.autoindent = true
o.cindent = true
o.shiftwidth = 4
o.softtabstop = 4
o.tabstop = 4