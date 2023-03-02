local fn = vim.fn
local g = vim.g
local cmd = vim.cmd
local lsp = vim.lsp
local api = vim.api
local map = require('utils').map

-- Ensure packer installed
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    cmd('packadd packer.nvim')
end

return require('packer').startup(function(use)
    use('wbthomason/packer.nvim')
    use('nvim-lua/plenary.nvim')

    use('folke/tokyonight.nvim')
    use('tpope/vim-fugitive') -- git fugitive
    use({
        'lewis6991/gitsigns.nvim',
        config = function()
            require('config.gitsigns')
        end,
    })
    use({
        'folke/which-key.nvim',
        config = function()
            require('which-key').setup({
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
            })
        end,
    })
    use({
        'folke/trouble.nvim',
        config = function()
            require('config.trouble')
        end,
    })
    use({
        'lukas-reineke/indent-blankline.nvim',
        config = function()
            require('config.indent-blankline')
        end,
    })
    use({
        'MattesGroeger/vim-bookmarks',
        requires = 'tom-anders/telescope-vim-bookmarks.nvim',
        config = function()
            require('config.nvim_bookmarks')
        end,
    })
    use({
        'ojroques/vim-oscyank',
        config = function()
            require('config.vim-oscyank')
        end,
    })
    use('junegunn/vim-easy-align') -- 可以快速对齐的插件
    use({
        't9md/vim-choosewin',
    })
    use({
        'akinsho/toggleterm.nvim',
        config = function()
            require('config.toggleterm')
        end,
    })
    use('wakatime/vim-wakatime')
    --use('psf/black')
    use({
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end,
    })
    use({
        'windwp/nvim-autopairs',
        config = function()
            -- nvim-autopairs
            require('nvim-autopairs').setup({})
        end,
    })
    use({
        'kyazdani42/nvim-tree.lua',
        requires = 'kyazdani42/nvim-web-devicons',
        config = function()
            require('config.nvim-tree')
        end,
    })
    use({
        'nvim-telescope/telescope.nvim',
        config = function()
            require('config.nvim_telescope')
        end,
    })
    use({
        'hrsh7th/nvim-cmp',
        config = function()
            require('config.nvim_cmp')
        end,
        requires = {
            'hrsh7th/cmp-vsnip',
            'hrsh7th/vim-vsnip',
            'hrsh7th/vim-vsnip-integ',
        },
    })
    use('hrsh7th/cmp-buffer')
    use({
        'folke/lsp-colors.nvim',
        config = function()
            require('lsp-colors').setup({})
        end,
    })
    use({
        'RishabhRD/nvim-lsputils',
        config = function()
            require('config.nvim-lsputils')
        end,
    })
    use({
        'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
        config = function()
            require('config.lsp_lines')
        end,
    })
    use({
        'github/copilot.vim',
        setup = function()
            vim.g.copilot_no_tab_map = 1
            vim.g.copilot_no_maps = 1
            vim.g.copilot_assume_mapped = 1
        end,
        config = function()
            local map = require('utils').map
            map('i', '<C-e>', 'copilot#Accept()', { expr = true })
        end,
    })
    use({
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = function()
            require('config.nvim_treesitter')
        end,
        requires = {
            'nvim-treesitter/playground',
            'nvim-treesitter/nvim-treesitter-refactor',
            'nvim-treesitter/nvim-treesitter-textobjects',
            'nvim-treesitter/nvim-treesitter-context',
            'RRethy/nvim-treesitter-endwise',
            'andymass/vim-matchup', -- extend % key
            'yioneko/nvim-yati',
            'm-demare/hlargs.nvim',
        },
    })
    use({
        'iamcco/markdown-preview.nvim',
        run = 'cd app && npm install',
        setup = function()
            vim.g.mkdp_filetypes = { 'markdown' }
        end,
        ft = { 'markdown' },
    })
    use({
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true },
        config = function()
            require('config.lualine')
        end,
    })
    use({
        'j-hui/fidget.nvim',
        config = function()
            require('fidget').setup({})
        end,
    })
    -- use 'arkav/lualine-lsp-progress'
    use({
        'romgrk/barbar.nvim',
        requires = { 'kyazdani42/nvim-web-devicons' },
    })
    use({
        'folke/todo-comments.nvim',
        config = function()
            require('todo-comments').setup({})
        end,
    })
    use({
        'phaazon/hop.nvim',
        as = 'hop',
        config = function()
            -- you can configure Hop the way you like here; see :h hop-config
            require('config.nvim_hop')
        end,
    })
    use({
        'preservim/tagbar',
        config = function()
            require('config.tagbar')
        end,
    })
    -- BETTER editor
    use({
        'vinnymeller/swagger-preview.nvim',
        run = "npm install -g swagger-ui-watcher",
        config = function()
            require("swagger-preview").setup({
                -- The port to run the preview server on
                port = 9000,
                -- The host to run the preview server on
                host = "localhost",
            })
        end,
    })

    -- LANGUAGES
    use({
        'Junnplus/lsp-setup.nvim',
        config = function()
            require('config.lsp-setup')
        end,
        requires = {
            'neovim/nvim-lspconfig',
            'hrsh7th/cmp-nvim-lsp',
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            'folke/lsp-colors.nvim',
            'folke/neodev.nvim',
            'ray-x/lsp_signature.nvim',

            'RRethy/vim-illuminate',
            'simrat39/rust-tools.nvim',
            'p00f/clangd_extensions.nvim',
        },
    })
    --use({
    --'neovim/nvim-lspconfig',
    --})
    --use({
    --'williamboman/nvim-lsp-installer',
    --config = function()
    --require('config.nvim-lsp-installer')
    --end,
    --})
    -- k8s
    use('andrewstuart/vim-kubernetes')

    -- go
    use({
        'fatih/vim-go',
        run = ':GoUpdateBinaries',
        config = function()
            require('config.nvim_vimgo')
        end,
    })
    -- erlang
    use('vim-erlang/vim-erlang-tags')
    use('iamcco/mathjax-support-for-mkdp')
    --beancount
    use('nathangrigg/vim-beancount')
    -- python
    use('Vimjas/vim-python-pep8-indent')
    -- rust
    use('rust-lang/rust.vim')
    use('mfussenegger/nvim-dap')
end)

-- require("todo-comments").setup {}
