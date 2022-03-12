local g = vim.g
local map = require('utils').map

-- floaterm
g['floaterm_keymap_new'] = '<F7>'
g['floaterm_keymap_next'] = '<F8>'
g['floaterm_keymap_prev'] = '<F9>'
g['floaterm_keymap_toggle'] = '<F10>'
g['floaterm_position'] = 'bottomright'
map('t', '<Esc>', '<c-\\><c-n>')
map('n', '<leader>t', 'V:FloatermSend<CR>:FloatermToggle<CR>')
map('v', '<leader>t', ':FloatermSend<CR>:FloatermToggle<CR>')
map('n', '<leader>r', 'V:FloatermSend<CR>:FloatermToggle<CR>')
map('v', '<leader>r', ':FloatermSend<CR>:FloatermToggle<CR>')
