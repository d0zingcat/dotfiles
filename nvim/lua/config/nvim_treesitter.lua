-- treesitter
require('nvim-treesitter.configs').setup({
    ensure_installed = { 'rust', 'go', 'python', 'lua', 'c' }, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
})
