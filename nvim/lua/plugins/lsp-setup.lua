return {
    'junnplus/lsp-setup.nvim',
    dependencies = {
        'neovim/nvim-lspconfig',
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'folke/neodev.nvim'
    },
    init = function()
        vim.lsp.set_log_level('debug')
        require('vim.lsp.log').set_format_func(vim.inspect)

        local rounded = { border = 'rounded' }
        vim.diagnostic.config({ float = rounded })
        local with_rounded = function(handler)
            return vim.lsp.with(handler, rounded)
        end
        vim.lsp.handlers['textDocument/hover'] = with_rounded(vim.lsp.handlers.hover)
        vim.lsp.handlers['textDocument/signatureHelp'] = with_rounded(vim.lsp.handlers.signature_help)
    end,
    opts = {
        mappings = {
            gd = function() require('telescope.builtin').lsp_definitions() end,
            gi = function() require('telescope.builtin').lsp_implementations() end,
            gr = function() require('telescope.builtin').lsp_references() end,
            ['<space>f'] = vim.lsp.buf.format,
        },
        inlay_hints = {
            enabled = true,
            debug = true,
        },
        servers = {
            eslint = {},
            pylsp = {
                settings = {
                    pylsp = {
                        -- PylspInstall python-lsp-black
                        -- PylspInstall pyls-isort
                        configurationSources = { 'flake8' },
                        plugins = {
                            pycodestyle = {
                                enabled = false,
                            },
                            mccabe = {
                                enabled = false,
                            },
                            pyflakes = {
                                enabled = false,
                            },
                            flake8 = {
                                enabled = true,
                            },
                            black = {
                                enabled = true,
                            }
                        }
                    }
                }
            },
            yamlls = {
                settings = {
                    yaml = {
                        keyOrdering = false
                    }
                }
            },
            crystalline = {},
            terraformls = {},
            jsonls = {},
            bashls = {},
            tsserver = {
                settings = {
                    typescript = {
                        inlayHints = {
                            includeInlayParameterNameHints = 'all',
                            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                            includeInlayFunctionParameterTypeHints = true,
                            includeInlayVariableTypeHints = true,
                            includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                            includeInlayPropertyDeclarationTypeHints = true,
                            includeInlayFunctionLikeReturnTypeHints = true,
                            includeInlayEnumMemberValueHints = true,
                        }
                    },
                }
            },
            dockerls = {},
            -- jsonnet_ls = {},
            helm_ls = {},
            gopls = {
                settings = {
                    gopls = {
                        gofumpt = true,
                        -- staticcheck = true,
                        usePlaceholders = true,
                        codelenses = {
                            gc_details = true,
                        },
                        hints = {
                            rangeVariableTypes = true,
                            parameterNames = true,
                            constantValues = true,
                            assignVariableTypes = true,
                            compositeLiteralFields = true,
                            compositeLiteralTypes = true,
                            functionTypeParameters = true,
                        },
                    },
                },
            },
            -- bufls = {},
            -- html = {},
            lua_ls = {
                settings = {
                    Lua = {
                        workspace = {
                            checkThirdParty = false,
                        },
                        hint = {
                            enable = true,
                            arrayIndex = 'Disable',
                        },
                    }
                }
            },
            ['rust_analyzer@nightly'] = {
                settings = {
                    ['rust-analyzer'] = {
                        diagnostics = {
                            disabled = { 'unresolved-proc-macro' },
                        },
                        cargo = {
                            loadOutDirsFromCheck = true,
                        },
                        procMacro = {
                            enable = true,
                        },
                        inlayHints = {
                            closureReturnTypeHints = {
                                enable = true
                            },
                        },
                        cache = {
                            warmup = false,
                        }
                    },
                },
            }
        }
    },
}
