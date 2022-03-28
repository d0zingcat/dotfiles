local g = vim.g
local map = require('utils').map

local Terminal = require('toggleterm.terminal').Terminal
local lazygit = Terminal:new({
    cmd = 'lazygit',
    dir = 'git_dir',
    close_on_exit = true,
    direction = 'float',
    float_opts = {
        border = 'double',
    },
    hidden = true,
    -- function to run on opening the terminal
    --on_open = function(term)
    --vim.cmd("startinsert!")
    --vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
    --end,
    -- function to run on closing the terminal
    --on_close = function(term)
    --vim.cmd("Closing terminal")
    --end,
})

function _lazygit_toggle()
    lazygit:toggle()
end

function _G.set_terminal_keymaps()
    local opts = { noremap = true }
    vim.api.nvim_buf_set_keymap(0, 't', '<C-b>', [[<C-\><C-n><C-w>]], opts)
    --vim.api.nvim_buf_set_keymap(0, 't', 'jk', [[<C-\><C-n>]], opts)
    --vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
    --vim.api.nvim_buf_set_keymap(0, 't', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
    --vim.api.nvim_buf_set_keymap(0, 't', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
    --vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', [[<C-\><C-n><C-W>l]], opts)
end

vim.api.nvim_set_keymap('n', '<leader>g', '<cmd>lua _lazygit_toggle()<CR>', { noremap = true, silent = true })

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

map('n', '<leader>tm', ':ToggleTerm size=15 direction=horizontal<CR>')

require('toggleterm').setup({})
