local cmd = vim.cmd
local g = vim.g
local map = require('utils').map

-- vim-bookmarks
require('telescope').load_extension('vim_bookmarks')

g['bookmark_sign'] = '⚑'
g['bookmark_highlight_lines'] = 1
g['bookmark_no_default_key_mappings'] = 1

cmd([[highlight BookmarkSign ctermbg=NONE ctermfg=160]])
cmd([[highlight BookmarkLine ctermbg=194 ctermfg=NONE]])

map('n', 'mm', ':BookmarkToggle<CR>')
map('n', 'mA', ':Telescope vim_bookmarks all<CR>')
map('n', 'ma', ':Telescope vim_bookmarks current_file<CR>')
-- map("n", "ma", ":BookmarkShowAll<CR>")
