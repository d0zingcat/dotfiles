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
                ['<C-k>'] = actions.move_selection_previous,
                ['<C-j>'] = actions.move_selection_next,
                ['<C-l>'] = { '<Right>', type = 'command' },
                ['<C-h>'] = { '<Left>', type = 'command' },
                ['<C-f>'] = actions.preview_scrolling_down,
                ['<C-b>'] = actions.preview_scrolling_up,
            },
        },
    },
})

local builtin = require('telescope.builtin')
map('n', '<leader>ff', builtin.find_files)
-- map('n', '<leader>fg', [[:lua require('telescope.builtin').live_grep({additional_args = {'-j8'}})<CR>]])
map('n', '<leader>fb', builtin.buffers)
map('n', '<leader>fg', function() builtin.live_grep({ additional_args = { '-j8' } }) end)
map('n', '<leader>fh', builtin.help_tags)
map('n', '<leader>;', builtin.commands)

-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require('telescope').load_extension('fzf')
