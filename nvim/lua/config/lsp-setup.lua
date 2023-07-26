local utils = require('lsp-setup.utils')
local mappings = {
    -- Example mappings for telescope pickers
    gd = 'lua require"telescope.builtin".lsp_definitions({jump_type="vsplit"})',
    gi = 'lua require"telescope.builtin".lsp_implementations({jump_type="vsplit"})',
    gr = 'lua require"telescope.builtin".lsp_references({jump_type="vsplit"})',
    go = 'lua require"telescope.builtin".lsp_document_symbols({jump_type="vsplit"})',
    ['<space>f'] = 'lua vim.lsp.buf.format({async=true})',
}

require("neodev").setup({
    -- add any options here, or leave empty to use the default settings
})

local servers = {
    lua_ls = {},
    bashls = {},
    yamlls = {
        filetypes = { 'yaml', 'yml' },
        settings = {
            yaml = {
                schemas = {
                    ['https://json.schemastore.org/github-workflow.json'] = '/.github/workflows/*',
                    ['https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json'] = {
                        '/*swagger.yaml',
                        '/*swagger.yml',
                    },
                    Kubernetes = {
                        '/*ingress.yaml',
                        '/*deployment.yaml',
                        '/*statefulset.yaml',
                        '/*configmap.yaml',
                        '/*secret.yaml',
                        '/*kustomization.yaml',
                        '/*service.yaml',
                    },
                    --['https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json'] = '/*.k8s.yaml',
                },
            },
        },
    },
    eslint = {},
    jsonls = {},
    clangd = {},
    gopls = {
        settings = {
            gopls = {
                gofumpt = true,
                usePlaceholders = true,
                staticcheck = true,
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
    terraformls = {},
    beancount = {
        filetypes = { 'beancount', 'bean' },
    }
}

local settings = {
    default_mappings = true,
    mappings = mappings,
    servers = servers,
}

require('lsp-setup').setup(settings)

-- require('lsp_signature').setup({})
require('lsp-colors').setup({})

local border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' }
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = border })
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border })
