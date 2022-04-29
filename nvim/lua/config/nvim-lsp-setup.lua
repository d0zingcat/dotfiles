local utils = require('nvim-lsp-setup.utils')
local mappings = {
        -- Example mappings for telescope pickers
         gd = 'lua require"telescope.builtin".lsp_definitions()',
         gi = 'lua require"telescope.builtin".lsp_implementations()',
         gr = 'lua require"telescope.builtin".lsp_references()',
         go = 'lua require"telescope.builtin".lsp_document_symbols()'
}

local servers = {
        -- Automatically install lsp server
        -- LSP server configuration please see: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
        bashls = {},
        yamlls = {
            filetypes = { 'yaml', 'yml' },
            settings = {
                yaml = {
                    schemas = {
                        ['https://json.schemastore.org/github-workflow.json'] = '/.github/workflows/*',
                        Kubernetes = { '/*k8s.yaml', '/*k8s.yml' },
                        --['https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json'] = '/*.k8s.yaml',
                    },
                },
            },
        },
        eslint = {},
        jsonls = {},
        clangd = require('nvim-lsp-setup.clangd_extensions').setup(),
        gopls = {
            settings = {
                golsp = {
                    gofumpt = true,
                    staticcheck = true,
                    useplaceholders = true,
                    codelenses = {
                        gc_details = true,
                    },
                },
            },
        },
        tsserver = {},
        prosemd_lsp = {},

        pylsp = {},
        rust_analyzer = {
            server = {
                settings = {
                    ['rust-analyzer'] = {
                        cargo = {
                            loadOutDirsFromCheck = true,
                        },
                        procMacro = {
                            enable = true,
                        },
                    },
                },
            },
        },
        -- Setup sumneko_lua with lua-dev
        sumneko_lua = require('lua-dev').setup({
            lspconfig = {
                on_attach = function(client, _)
                    -- Disable formatting
                    utils.disable_formatting(client)
                end,
            },
        }),
    }

local settings = {
    default_mappings = true,
    -- Default mappings
    -- gD = 'lua vim.lsp.buf.declaration()',
    -- gd = 'lua vim.lsp.buf.definition()',
    -- gt = 'lua vim.lsp.buf.type_definition()',
    -- gi = 'lua vim.lsp.buf.implementation()',
    -- gr = 'lua vim.lsp.buf.references()',
    -- K = 'lua vim.lsp.buf.hover()',
    -- ['<C-k>'] = 'lua vim.lsp.buf.signature_help()',
    -- ['<space>rn'] = 'lua vim.lsp.buf.rename()',
    -- ['<space>ca'] = 'lua vim.lsp.buf.code_action()',
    -- ['<space>f'] = 'lua vim.lsp.buf.formatting()',
    -- ['<space>e'] = 'lua vim.lsp.diagnostic.show_line_diagnostics()',
    -- ['[d'] = 'lua vim.lsp.diagnostic.goto_prev()',
    -- [']d'] = 'lua vim.lsp.diagnostic.goto_next()',
    mappings = mappings,
    -- Global on_attach
    -- on_attach = function(client, bufnr) {
    --     utils.format_on_save(client)
    -- }, 
     servers = servers,
}

require('nvim-lsp-setup').setup(settings)

local null_ls = require('null-ls')
null_ls.setup({
    sources = {
        null_ls.builtins.formatting.stylua.with({
            extra_args = { '--config-path', vim.fn.expand('~/.config/stylua/stylua.toml') },
        }),
    },
    on_attach = function(client)
        utils.format_on_save(client)
    end,
})

require('lsp_signature').setup({})
require('lsp-colors').setup({})

local border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' }
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = border })
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border })
