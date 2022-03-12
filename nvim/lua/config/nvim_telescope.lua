local map = require('utils').map

-- telescope
local actions = require('telescope.actions')
require('telescope').setup({
    defaults = {
        layout_config = {
            horizontal = {
                width = 0.75,
                height = 0.6,
            },
        },
        mappings = {
            i = {
                ['<esc>'] = actions.close,
                ['<C-j>'] = actions.move_selection_previous,
                ['<C-k>'] = actions.move_selection_next,
                ['<C-l>'] = { '<Right>', type = 'command' },
                ['<C-h>'] = { '<Left>', type = 'command' },
                ['<C-f>'] = actions.preview_scrolling_down,
                ['<C-b>'] = actions.preview_scrolling_up,
            },
        },
    },
})

map('n', '<leader>ff', '<cmd>Telescope find_files<cr>')
map('n', '<leader>fg', '<cmd>Telescope live_grep<cr>')
map('n', '<leader>fb', '<cmd>Telescope buffers<cr>')
map('n', '<leader>;', '<cmd>Telescope commands<cr>')
