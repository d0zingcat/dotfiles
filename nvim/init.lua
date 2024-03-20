local cmd = vim.cmd
local o_s = vim.o
local map_key = vim.api.nvim_set_keymap
local g = vim.g
local api = vim.api
local fn = vim.fn
local ncmd = vim.api.nvim_command
local o, wo, bo = vim.o, vim.wo, vim.bo

local buffer = { o, bo }
local window = { o, wo }


local utils = require('utils')
local map = utils.map
local set = utils.set

--vim.lsp.set_log_level('debug')
-- Preset
-- Prerequisites Must have neovim installed
if fn.has('nvim') == 0 then
    return
end


-- Ensure packer installed
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    cmd('packadd packer.nvim')
end

-- reopen last position
-- cmd([[ autocmd BufReadPost * normal! g`" ]])

-- Shcemas and colors
set('termguicolors', true) -- 开启24bit的颜色，开启这个颜色会更漂亮一些
cmd([[ colorscheme tokyonight ]])
--set('background', 'dark') -- 主题背景 dark-深色; light-浅色

-- CMDs
-- cmd [[syntax enable]]
-- cmd [[syntax on]] -- 开启文件类型侦测
cmd('filetype plugin indent on')
cmd([[ autocmd FileType php setlocal tabstop=2 shiftwidth=2 softtabstop=2 textwidth=120 ]])
cmd([[ autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4 ]])
cmd([[ autocmd FileType json setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab ]])
cmd([[ autocmd FileType go setlocal tabstop=8 shiftwidth=8 softtabstop=8 textwidth=120 noexpandtab ]])
-- in makefiles, don't expand tabs to spaces, since actual tab characters are
-- needed, and have indentation at 8 chars to be sure that all indents are tabs
-- (despite the mappings later):
cmd([[ autocmd FileType make set noexpandtab shiftwidth=8 softtabstop=0]])
cmd([[ autocmd FileType html,htmldjango,xhtml,haml setlocal tabstop=2 shiftwidth=2 softtabstop=2 textwidth=0 ]])
cmd([[ autocmd FileType yaml setlocal tabstop=2 shiftwidth=2 softtabstop=2 textwidth=0 expandtab ]])
cmd([[ autocmd FileType ruby setlocal tabstop=2 shiftwidth=2 softtabstop=2 textwidth=120 ]])
cmd([[ autocmd FileType less,sass,scss,css setlocal tabstop=2 shiftwidth=2 softtabstop=2 textwidth=120 ]])
cmd(
    [[ autocmd FileType javascript,javascript.jsx,javascriptreact,typescript,typescriptreact setlocal tabstop=2 shiftwidth=2 softtabstop=4 expandtab ]]
)

cmd([[iabbrev pdb import pdb; pdb.set_trace()<ESC>]])
cmd([[iabbrev ipdb import ipdb; ipdb.set_trace()<ESC>]])
-- auto compile packer
cmd([[
augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
augroup end
]])
-- autocmd BufRead,BufNewFile *.bean,*.beancount set filetype=beancount

-- cmd [[command ShowBlank set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:␣]]

-- Settings
-- max timeout for common command
set('timeoutlen', 1000)
-- set number, cusor or line/column
set('nu', true, window)
set('rnu', true, window)
set('cul', true, window)
set('cuc', true, window)

-- tab 缩进
-- set("tabstop", 4) -- 设置Tab长度为4空格
-- set("shiftwidth", 4) -- 设置自动缩进长度为4空格
-- set("autoindent", true) -- 继承前一行的缩进方式，适用于多行注释
-- set("colorcolumn", "80") -- 设置长度提示79
-- set('noswapfile', true) -- 不设置swap文件

set('showmatch', true) -- 显示括号匹配
set('mouse', 'a')      -- set scroll mode
set('langmenu', 'zh_CN.UTF-8')
set('helplang', 'cn')
set('encoding', 'utf-8')
set('fencs', 'utf-8,ucs-bom,shift-jis,gb18030,gbk,gb2312,cp936')
set('hidden', true)
set('wildmenu', true)
set('hlsearch', true)
set('matchtime', 1)
set('updatetime', 100)
set('smarttab', true)
set('expandtab', true)
set('laststatus', 2)
set('showcmd', true)
set('ruler', true)
set('history', 300)
set('backup', false)
set('swapfile', false)
set('foldenable', false)
set('autoread', true)
set('autowrite', true)
set('mouse', 'a')
set('incsearch', true)  -- 开启实时搜索
set('ignorecase', true) -- 搜索时大小写不敏感

set('number', true, window)
-- set('relativenumber', true, window)
set('cursorline', true, window)
set('cursorcolumn', true, window)
set('signcolumn', 'auto:2')

-- set("textwidth", 120, buffer)
set('smartindent', true, buffer)
set('autoindent', true, buffer)
set('cindent', true, buffer)
set('shiftwidth', 4, buffer)
set('softtabstop', 4, buffer)
set('tabstop', 4, buffer)
set('synmaxcol', 120)

-- set autowrite
-- set("backspace", "indent,eol,start")

-- Key mappings
-- map Leader key to <space>
g.mapleader = [[ ]]

-- v 模式下复制内容到系统剪切板
map('v', '<Leader>cp', '"+yy')
-- n 模式下复制一行到系统剪切板
map('n', '<Leader>cp', '"+yy')
-- n 模式下粘贴系统剪切板的内容
map('n', '<Leader>v', '"+p')
-- reload vimrc
map('n', '<leader>rv', ':source $MYVIMRC<CR>')

-- insert mode mapping
--map('i', '<c-b>', '<c-o>b')
--map('i', '<c-f>', '<c-o>l')
--map('i', '<c-j>', '<c-o>j')
--map('i', '<c-k>', '<c-o>k')

map('n', '<F1>', '<nop>')
map('i', '<F1>', '<nop>')

--map('i', '<c-k>', '<up>')
--map('i', '<c-j>', '<down>')
--map('i', '<c-h>', '<left>')
--map('i', '<c-l>', '<right>')

-- map('n', '<leader>e', '1<c-w>w')
-- map('n', '<leader>p', ':wincmd p<CR>')

map('i', '<C-e>', 'copilot#Accept()', { expr = true })
vim.g.copilot_no_tab_map = 1
vim.g.copilot_no_maps = 1
vim.g.copilot_assume_mapped = 1


require('plugins')
require('funcs')

-- Neoformat
if not fn.executable('luafmt') then
    cmd([[ :!npm install -g lua-fmt]])
end

-- barbar
local opts = { noremap = true, silent = true }
map('n', '=', ':BufferPick<CR>', opts)

-- choosewin
map('n', '-', '<Plug>(choosewin)', { noremap = false })

-- sort go imports
-- vim.api.nvim_create_autocmd('BufWritePre', {
--     pattern = '*.go',
--     callback = function()
--         vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })
--     end
-- })

vim.api.nvim_set_keymap('n', '<leader>of', ':lua OpenFinder()<CR>', { noremap = true, silent = true })

function OpenFinder()
    local current_path = vim.fn.expand('%:p:h')
    vim.cmd('!open ' .. current_path)
end

-- Some configurations not able to migrate
api.nvim_exec(
    [[
" set nocompatible
"function! NearestMethodOrFunction() abort
"  return get(b:, 'vista_nearest_method_or_function', '')
"endfunction
"
"set statusline+=%{NearestMethodOrFunction()}
]],
    false
)
