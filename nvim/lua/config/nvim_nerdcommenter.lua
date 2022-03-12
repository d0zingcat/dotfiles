local map = require('utils').map
local g = vim.g

-- nerdcommenter
map('', '<leader>cc', 'V}:call NERDComment("x", "toggle")<CR>')
map('', '<leader>cu', 'V{:call NERDComment("x", "toggle")<CR>')
g['NERDTrimTrailingWhitespace'] = 1
g['NERDSpaceDelims'] = 1
