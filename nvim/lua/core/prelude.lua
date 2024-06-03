if vim.fn.has('nvim') == 0 then
    return
end

vim.o.termguicolors = true

vim.g.mapleader = " "       -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.maplocalleader = "\\" -- Same for `maplocalleader`
