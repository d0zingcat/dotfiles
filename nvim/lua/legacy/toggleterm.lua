local g = vim.g
local map = require('utils').map

map('t', '<C-]>', [[<C-\><C-n>]], { noremap = true })

require('toggleterm').setup({
    open_mapping = [[<C-t>]],
    size = function(term)
        if term.direction == 'horizontal' then
            return 15
        else
            return vim.o.columns * 0.3
        end
    end,
})
