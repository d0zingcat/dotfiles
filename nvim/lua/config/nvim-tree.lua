local g = vim.g
local map = require('utils').map

local tree_cb = require('nvim-tree.config').nvim_tree_callback
require('nvim-tree').setup({
    view = {
        width = 35,
        side = 'left',
        mappings = {
            list = {
                { key = '<C-v>', cb = tree_cb('vsplit') },
                { key = '<C-s>', cb = tree_cb('split') },
                { key = 'v', cb = tree_cb('vsplit') },
                { key = 's', cb = tree_cb('split') },
                { key = '-', cb = '<Plug>(choosewin)' },
                { key = '<C-t>', cb = ':ToggleTerm<cr>' },
            },
        },
    },
    renderer = {
        highlight_opened_files = '1',
    },
    diagnostics = {
        enable = true,
        icons = {
            error = '',
            warning = '',
            info = '',
            hint = '',
        },
    },
    update_to_buf_dir = {
        enable = true,
        auto_update = true,
    },
    update_focused_file = {
        enable = true,
    },
    filters = {
        custom = { '.git' }, -- ignore .git
    },
    --auto_close = true,
    hijack_netrw = true,
    update_cwd = true,
    focus_tree = false,
    open_on_setup = true,
})

map('n', '<leader>te', ':NvimTreeToggle<CR>')

vim.cmd([[
autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif
augroup nvimtree
  autocmd VimEnter * lua require('nvim-tree').toggle(false, true)
augroup END
]])
