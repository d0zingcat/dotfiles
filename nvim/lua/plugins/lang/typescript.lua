-- lang/typescript.lua - TypeScript/JavaScript 开发专用配置

return {
  -- typescript-tools.nvim - 高性能 TypeScript LSP（直接对接 tsserver 协议）
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
    opts = {
      on_attach = function(_, bufnr)
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
        end
        map("n", "<leader>to", "<cmd>TSToolsOrganizeImports<cr>", "整理 Import")
        map("n", "<leader>ta", "<cmd>TSToolsAddMissingImports<cr>", "添加缺失 Import")
        map("n", "<leader>tu", "<cmd>TSToolsRemoveUnusedImports<cr>", "删除未使用 Import")
        map("n", "<leader>tf", "<cmd>TSToolsFixAll<cr>", "修复所有")
        map("n", "<leader>tr", "<cmd>TSToolsRenameFile<cr>", "重命名文件")
        map("n", "<leader>tR", "<cmd>TSToolsFileReferences<cr>", "文件引用")
      end,
      settings = {
        separate_diagnostic_server = true,
        publish_diagnostic_on = "insert_leave",
        expose_as_code_action = "all",
        tsserver_path = nil,
        tsserver_plugins = {},
        tsserver_max_memory = "auto",
        tsserver_format_options = {
          allowIncompleteCompletions = false,
          allowRenameOfImportPath = false,
        },
        tsserver_file_preferences = {
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = false,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
          quotePreference = "auto",
        },
        -- 代码样式
        tsserver_locale = "zh-cn",
        complete_function_calls = true,
        include_completions_with_insert_text = true,
        code_lens = "off",
        disable_member_code_lens = true,
        jsx_close_tag = { enable = true, filetypes = { "javascriptreact", "typescriptreact" } },
      },
    },
  },

  -- ESLint LSP（通过 nvim-lspconfig，mason 安装）
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = {
      servers = {
        eslint = {
          settings = {
            workingDirectories = { mode = "auto" },
            format = false, -- 格式化由 prettier 处理
          },
          on_attach = function(_, bufnr)
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              command = "EslintFixAll",
            })
          end,
        },
      },
    },
  },

  -- Mason TypeScript 工具
  {
    "williamboman/mason.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "typescript-language-server", "eslint-lsp", "prettierd",
      })
    end,
  },

  -- Treesitter TypeScript/JSX
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "javascript", "typescript", "tsx", "jsdoc",
      })
    end,
  },
}
