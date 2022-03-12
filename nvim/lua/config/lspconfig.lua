local lsp = vim.lsp
local api = vim.api
local cmd = vim.cmd

local lsp_installer = require('nvim-lsp-installer')
local lsp_installer_servers = require('nvim-lsp-installer.servers')

-- lspconfig && lspinstaller
local on_attach = function(client, bufnr)
    local function buf_set_keymap(...)
        api.nvim_buf_set_keymap(bufnr, ...)
    end
    local function buf_set_option(...)
        api.nvim_buf_set_option(bufnr, ...)
    end
    --require "lsp_signature".on_attach()

    -- Enable completion triggered by <c-x><c-o>
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = { noremap = true, silent = true }

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', '<C-y>', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    buf_set_keymap('n', 'gr', '<cmd>Telescope lsp_references<CR>', opts)
    buf_set_keymap('n', 'gd', '<cmd>Telescope lsp_definitions<CR>', opts)
    buf_set_keymap('n', 'go', '<cmd>Telescope lsp_document_symbols<CR>', opts)
    buf_set_keymap('n', 'gO', '<cmd>Telescope lsp_workspace_symbols<CR>', opts)
    --buf_set_keymap("n", "<space>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
    buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
    buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

    if client.resolved_capabilities.document_formatting then
        vim.cmd([[
          augroup Format
            au! * <buffer>
            au BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)
          augroup END
        ]])
    end
end

local capabilities = lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
lsp_installer.on_server_ready(function(server)
    local opts = {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = {
            debounce_text_changes = 150,
        },
    }

    if server.name == 'sumneko_lua' then
        local luadev = require('lua-dev').setup({
            lspconfig = {
                settings = {
                    Lua = {
                        workspace = {
                            checkThirdParty = false,
                        },
                    },
                },
            },
        })
        opts = vim.tbl_deep_extend('force', opts, luadev)
    end

    if server.name == 'yamlls' then
        --local yamlls_opts = {
        --settings = {
        --yaml = {
        --filetypes = { 'yaml', 'yml' },
        --schemaStore = {
        --enable = true,
        --url = 'https://www.schemastore.org/api/json/catalog.json',
        --},
        --validate = false,
        --schemas = {
        --['https://json.schemastore.org/github-workflow.json'] = '/.github/workflows/*',
        --kubernetes = '/*.k8s.yaml',
        --},
        --},
        --},
        --}
        local conf = require(string.format('config.lsp_servers.%s', server.name))
        opts = vim.tbl_deep_extend('force', opts, conf)
    end
    -- (optional) Customize the options passed to the server
    -- if server.name == "tsserver" then
    --     opts.root_dir = function() ... end
    -- end

    -- This setup() function is exactly the same as lspconfig's setup function.
    -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
    server:setup(opts)
end)

local null_ls = require('null-ls')
null_ls.setup({
    sources = {
        null_ls.builtins.formatting.stylua.with({
            extra_args = { '--config-path', vim.fn.expand('~/.config/stylua.toml') },
        }),
        null_ls.builtins.formatting.shfmt,
    },
    on_attach = on_attach,
})
