local g = vim.g
local map = require('utils').map

map('n', '<leader>te', ':NERDTreeToggle<CR>')

vim.cmd([[
    autocmd VimEnter * NERDTree | wincmd p
    autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

    autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

]])
