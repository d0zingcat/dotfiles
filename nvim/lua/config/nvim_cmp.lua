local fn = vim.fn

-- nvim-cmp
local cmp = require('cmp')
cmp.setup({
    snippet = {
        expand = function(args)
            fn['vsnip#anonymous'](args.body)
        end,
    },
    formatting = {
        format = function(entry, vim_item)
            -- set a name for each source
            vim_item.menu = ({
                buffer = '[Buf]',
                nvim_lsp = '[LSP]',
                luasnip = '[Snip]',
                nvim_lua = '[Lua]',
                latex_symbols = '[Latex]',
            })[entry.source.name]
            return vim_item
        end,
    },
    mapping = {
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        --["<C-e>"] = cmp.mapping.close(),
        ['<C-e>'] = function(fallback)
            fallback()
        end,
        ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        }),
    },
    sources = {
        { name = 'nvim_lsp' },
        { name = 'buffer' },
    },
})
