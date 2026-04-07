-- lsp.lua - LSP 核心配置（lazydev + mason + nvim-lspconfig + fidget）

return {
  -- Lua 开发辅助（替代已废弃的 neodev.nvim）
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim%.uv" } },
        { path = "nvim-dap-ui" },
      },
    },
  },
  { "Bilal2453/luvit-meta", lazy = true },

  -- LSP 进度提示
  {
    "j-hui/fidget.nvim",
    opts = {
      notification = { window = { winblend = 0 } },
    },
  },

  -- Mason 工具管理器
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    opts = {
      ui = { border = "rounded", icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" } },
    },
  },

  -- mason-lspconfig 桥接
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "lua_ls",
        "gopls",
        "pyright",
        "ruff",
        "ts_ls",
        "eslint",
        "jsonls",
        "yamlls",
        "bashls",
      },
      automatic_installation = true,
    },
  },

  -- mason 工具安装器（格式化/lint 工具）
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        -- Go
        "gofumpt", "goimports", "golangci-lint", "delve",
        -- Rust（通过 rustup 管理，mason 作为备用）
        "codelldb",
        -- Python
        "isort", "debugpy",
        -- JS/TS
        "prettierd", "eslint_d",
        -- 通用
        "stylua", "shfmt", "shellcheck", "selene",
      },
    },
  },

  -- nvim-lspconfig 主配置
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    opts = {
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = " ",
            [vim.diagnostic.severity.INFO] = " ",
          },
        },
      },
      inlay_hints = { enabled = true },
      -- 各语言服务器配置（Rust 由 rustaceanvim 接管，不在此处配置）
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = "Replace" },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
              diagnostics = { globals = { "vim" } },
            },
          },
        },
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
              },
            },
          },
        },
        ruff = {
          -- ruff 处理 import 排序和快速修复，格式化由 conform 接管
          on_attach = function(client)
            client.server_capabilities.documentFormattingProvider = false
          end,
        },
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              codelenses = {
                gc_details = true, generate = true, run_govulncheck = true,
                test = true, tidy = true, upgrade_dependency = true,
              },
              hints = {
                assignVariableTypes = true, compositeLiteralFields = true,
                compositeLiteralTypes = true, constantValues = true,
                functionTypeParameters = true, parameterNames = true,
                rangeVariableTypes = true,
              },
              analyses = {
                fieldalignment = true, nilness = true,
                unusedparams = true, unusedwrite = true, useany = true,
              },
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true,
              directoryFilters = { "-.git", "-.vscode", "-.idea", "-node_modules" },
              semanticTokens = true,
            },
          },
        },
        -- ts_ls 由 typescript-tools.nvim 接管，此处不配置
        eslint = {},
        jsonls = {
          -- 延迟加载 schemastore（插件安装后才可用）
          on_new_config = function(new_config)
            new_config.settings = new_config.settings or {}
            new_config.settings.json = new_config.settings.json or {}
            new_config.settings.json.schemas = new_config.settings.json.schemas or {}
            local ok, schemastore = pcall(require, "schemastore")
            if ok then
              vim.list_extend(new_config.settings.json.schemas, schemastore.json.schemas())
            end
          end,
          settings = {
            json = { validate = { enable = true } },
          },
        },
        yamlls = {},
        bashls = {},
      },
    },
    config = function(_, opts)
      -- 诊断符号
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      -- LspAttach 公共键绑定
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local buf = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, desc = desc })
          end

          -- 导航
          map("n", "gd", function() vim.lsp.buf.definition() end, "转到定义")
          map("n", "gD", function() vim.lsp.buf.declaration() end, "转到声明")
          map("n", "gr", function() vim.lsp.buf.references() end, "查找引用")
          map("n", "gI", function() vim.lsp.buf.implementation() end, "转到实现")
          map("n", "gt", function() vim.lsp.buf.type_definition() end, "转到类型定义")
          map("n", "K", function() vim.lsp.buf.hover() end, "悬浮文档")
          map("n", "gK", function() vim.lsp.buf.signature_help() end, "签名帮助")
          map("i", "<C-k>", function() vim.lsp.buf.signature_help() end, "签名帮助")

          -- 操作
          map({ "n", "v" }, "<leader>ca", function() vim.lsp.buf.code_action() end, "代码操作")
          map("n", "<leader>cr", function()
            -- inc-rename 若已加载则使用增量重命名，否则回退到标准 LSP rename
            local ok, inc = pcall(require, "inc_rename")
            if ok then
              return ":" .. inc.rename.cmd .. " " .. vim.fn.expand("<cword>")
            end
            vim.lsp.buf.rename()
          end, "重命名")
          map("n", "<leader>cl", "<cmd>LspInfo<cr>", "LSP 信息")

          -- 诊断
          map("n", "]d", function() vim.diagnostic.goto_next() end, "下一个诊断")
          map("n", "[d", function() vim.diagnostic.goto_prev() end, "上一个诊断")
          map("n", "<leader>cd", function() vim.diagnostic.open_float() end, "行诊断")

          -- Inlay hints 切换
          if client and client.supports_method("textDocument/inlayHint") then
            map("n", "<leader>uh", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
            end, "切换 Inlay Hints")
          end
        end,
      })

      -- 构建 capabilities（blink.cmp 提供）
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- 通过 mason-lspconfig 自动启动服务器
      require("mason-lspconfig").setup_handlers({
        function(server)
          local server_opts = vim.tbl_deep_extend("force", {
            capabilities = vim.deepcopy(capabilities),
          }, opts.servers[server] or {})

          -- Rust 由 rustaceanvim 接管，跳过
          if server == "rust_analyzer" then return end
          -- TypeScript 由 typescript-tools.nvim 接管，跳过
          if server == "ts_ls" or server == "tsserver" then return end

          require("lspconfig")[server].setup(server_opts)
        end,
      })
    end,
  },

  -- JSON Schema Store（可选，供 jsonls 使用）
  { "b0o/SchemaStore.nvim", lazy = true },

  -- 增量重命名（在命令行实时预览）
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    opts = {},
  },
}
