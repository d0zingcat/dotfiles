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
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        -- ['<C-e>'] = cmp.mapping.complete(),
        --["<C-e>"] = cmp.mapping.close(),
        ['<C-e>'] = function(fallback)
            fallback()
        end,
        -- ['<CR>'] = cmp.mapping.confirm({
        --     behavior = cmp.ConfirmBehavior.Replace,
        --     select = true,
        -- }),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        -- ['<C-n>'] = cmp.mapping.select_next_item(),
        -- ['<C-p>'] = cmp.mapping.select_prev_item(),
        --},
    }),
    sources = {
        { name = 'nvim_lsp' },
        { name = 'buffer' },
    },
})
