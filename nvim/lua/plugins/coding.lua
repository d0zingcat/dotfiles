-- coding.lua - 代码增强插件配置

return {
  -- LSP 配置
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      -- LSP 管理器
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },
      
      -- 自动安装 LSP
      { "WhoIsSethDaniel/mason-tool-installer.nvim" },
      
      -- 显示 LSP 进度
      { "j-hui/fidget.nvim", opts = {} },
      
      -- 额外 LSP 功能
      { "folke/neodev.nvim", opts = {} },
    },
    opts = {
      -- LSP 服务器诊断设置
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "✘",
            [vim.diagnostic.severity.WARN] = "▲",
            [vim.diagnostic.severity.HINT] = "⚑",
            [vim.diagnostic.severity.INFO] = "»",
          },
        },
      },
      
      -- 自动格式化
      format = {
        formatting_options = nil,
        timeout_ms = 1000,
      },
      
      -- LSP 服务器设置
      servers = {
        -- 根据语言配置服务器
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
              workspace = {
                checkThirdParty = false,
              },
              telemetry = {
                enable = false,
              },
              diagnostics = {
                globals = { "vim" },
              },
            },
          },
        },
        
        -- Python 服务器
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
        ruff_lsp = {
          -- Ruff 会处理导入和排序
          init_options = {
            settings = {
              args = {},
            },
          },
        },
        
        -- Go 服务器
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              codelenses = {
                gc_details = true,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              analyses = {
                fieldalignment = true,
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
                shadow = true,
              },
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true,
              directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
              semanticTokens = true,
            },
          },
        },
      },
      
      -- 自动设置功能
      setup = {
        ruff_lsp = function()
          require("lazyvim.util").lsp.on_attach(function(client, _)
            -- 禁用 ruff 格式化功能，由 none-ls 处理
            if client.name == "ruff_lsp" then
              client.server_capabilities.documentFormattingProvider = false
            end
          end)
        end,
      },
    },
    config = function(_, opts)
      -- 设置诊断标志
      for name, icon in pairs(opts.diagnostics.signs.text) do
        name = "DiagnosticSign" .. name
        vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
      end
      
      -- 配置诊断
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))
      
      -- 设置 LSP 的键绑定和自动命令
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local buffer = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          
          -- 设置 LSP 键绑定
          local map = function(mode, l, r, opts_)
            opts_ = opts_ or {}
            opts_.silent = true
            opts_.buffer = buffer
            vim.keymap.set(mode, l, r, opts_)
          end
          
          -- 导航键绑定
          map("n", "gd", "<cmd>Telescope lsp_definitions<cr>", { desc = "转到定义" })
          map("n", "gr", "<cmd>Telescope lsp_references<cr>", { desc = "查找引用" })
          map("n", "gD", vim.lsp.buf.declaration, { desc = "转到声明" })
          map("n", "gI", "<cmd>Telescope lsp_implementations<cr>", { desc = "转到实现" })
          map("n", "gt", "<cmd>Telescope lsp_type_definitions<cr>", { desc = "转到类型定义" })
          map("n", "K", vim.lsp.buf.hover, { desc = "显示悬停信息" })
          map("n", "gK", vim.lsp.buf.signature_help, { desc = "显示签名帮助" })
          
          -- 代码操作键绑定
          map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "代码操作" })
          map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "重命名" })
          
          -- 诊断键绑定
          map("n", "]d", vim.diagnostic.goto_next, { desc = "下一个诊断" })
          map("n", "[d", vim.diagnostic.goto_prev, { desc = "上一个诊断" })
          map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "行诊断" })
          map("n", "<leader>cl", "<cmd>LspInfo<cr>", { desc = "LSP 信息" })
          
          -- 格式化文档（如果服务器支持）
          if client and client.supports_method("textDocument/formatting") then
            map("n", "<leader>cf", vim.lsp.buf.format, { desc = "格式化代码" })
          end
        end,
      })
      
      -- 设置 LSP 服务器
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        require("cmp_nvim_lsp").default_capabilities(),
        opts.capabilities or {}
      )
      
      -- 为 Lua 开发环境配置
      require("neodev").setup({
        library = {
          plugins = { "nvim-dap-ui" },
          types = true,
        },
      })
      
      -- 设置 mason-lspconfig
      require("mason").setup()
      
      local ensure_installed = {} -- 要安装的服务器列表
      
      -- 收集需要安装的服务器
      for server, server_opts in pairs(opts.servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          -- 将服务器添加到安装列表
          ensure_installed[#ensure_installed + 1] = server
        end
      end
      
      -- 设置 mason-lspconfig
      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(ensure_installed),
        automatic_installation = true,
      })
      
      -- 设置工具安装程序
      require("mason-tool-installer").setup({
        ensure_installed = {
          -- Python 工具
          "black",
          "isort",
          "mypy",
          "ruff",
          "debugpy",
          
          -- Go 工具
          "gofumpt",
          "goimports",
          "golangci-lint",
          "delve",
          
          -- 通用工具
          "stylua",
          "shfmt",
        },
      })
      
      -- 启动服务器
      require("mason-lspconfig").setup_handlers({
        function(server)
          local server_opts = vim.tbl_deep_extend("force", {
            capabilities = vim.deepcopy(capabilities),
          }, opts.servers[server] or {})
          
          -- 特殊设置钩子
          if opts.setup[server] then
            if opts.setup[server](server, server_opts) then
              return
            end
          end
          
          -- 启动服务器
          require("lspconfig")[server].setup(server_opts)
        end,
      })
    end,
  },
  
  -- 自动完成
  {
    "hrsh7th/nvim-cmp",
    version = false,
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-cmdline",
    },
    opts = function()
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      
      local function has_words_before()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end
      
      return {
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<S-CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip", priority = 750 },
          { name = "buffer", priority = 500 },
          { name = "path", priority = 250 },
        }),
        formatting = {
          format = function(entry, vim_item)
            -- 添加源信息
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snip]",
              buffer = "[Buf]",
              path = "[Path]",
            })[entry.source.name]
            
            -- 设置最大宽度
            local MAX_LABEL_WIDTH = 50
            if #vim_item.abbr > MAX_LABEL_WIDTH then
              vim_item.abbr = vim_item.abbr:sub(1, MAX_LABEL_WIDTH) .. "..."
            end
            
            return vim_item
          end,
        },
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
        },
      }
    end,
    config = function(_, opts)
      -- 设置 nvim-cmp
      local cmp = require("cmp")
      cmp.setup(opts)
      
      -- 为命令行设置完成
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
          { name = "cmdline" },
        }),
      })
      
      -- 为搜索设置完成
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "buffer" },
        }),
      })
    end,
  },
  
  -- 代码格式化和 Linting
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ lsp_fallback = true, async = false })
        end,
        mode = { "n", "v" },
        desc = "格式化代码",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        go = { "goimports", "gofumpt" },
        javascript = { "prettierd" },
        typescript = { "prettierd" },
        javascriptreact = { "prettierd" },
        typescriptreact = { "prettierd" },
        json = { "prettierd" },
        html = { "prettierd" },
        css = { "prettierd" },
        yaml = { "prettierd" },
        markdown = { "prettierd" },
        sh = { "shfmt" },
      },
      
      -- 每个格式化工具的设置
      formatters = {
        black = {
          args = { "--line-length", "88", "--fast", "-" },
        },
        isort = {
          args = { "--stdout", "--profile", "black", "--line-length", "88", "-" },
        },
        stylua = {
          args = { "--indent-type", "Spaces", "--indent-width", "2", "-" },
        },
      },
      
      -- 保存时自动格式化
      format_on_save = function(bufnr)
        if vim.b[bufnr].disable_autoformat or vim.g.disable_autoformat then
          return
        end
        return { timeout_ms = 500, lsp_fallback = true }
      end,
      
      -- 格式化超时时间
      format_after_save = function(bufnr)
        if vim.b[bufnr].disable_autoformat or vim.g.disable_autoformat then
          return
        end
        return { lsp_fallback = true }
      end,
    },
    init = function()
      -- 添加用户命令以切换格式化
      vim.api.nvim_create_user_command("FormatToggle", function(args)
        if args.bang then
          -- FormatToggle! 将为当前缓冲区切换格式化
          vim.b.disable_autoformat = not vim.b.disable_autoformat
          vim.notify(string.format("Buffer autoformatting %s", vim.b.disable_autoformat and "disabled" or "enabled"))
        else
          -- FormatToggle 将全局切换格式化
          vim.g.disable_autoformat = not vim.g.disable_autoformat
          vim.notify(string.format("Global autoformatting %s", vim.g.disable_autoformat and "disabled" or "enabled"))
        end
      end, { desc = "切换自动格式化", bang = true })
    end,
  },
  
  -- 调试支持
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- UI 相关
      {
        "rcarriga/nvim-dap-ui",
        keys = {
          { "<leader>du", function() require("dapui").toggle() end, desc = "Dap UI" },
        },
        opts = {},
        config = function(_, opts)
          local dap = require("dap")
          local dapui = require("dapui")
          dapui.setup(opts)
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
          end
        end,
      },
      -- 虚拟文本支持
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {},
      },
      -- Python 调试支持
      {
        "mfussenegger/nvim-dap-python",
        config = function()
          local path = require("mason-registry").get_package("debugpy"):get_install_path()
          require("dap-python").setup(path .. "/venv/bin/python")
        end,
      },
      -- Go 调试支持
      {
        "leoluz/nvim-dap-go",
        config = true,
      },
    },
    keys = {
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('断点条件: ')) end, desc = "条件断点" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "切换断点" },
      { "<leader>dc", function() require("dap").continue() end, desc = "继续执行" },
      { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "带参数运行" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "运行到光标处" },
      { "<leader>dg", function() require("dap").goto_() end, desc = "跳转到行" },
      { "<leader>di", function() require("dap").step_into() end, desc = "单步进入" },
      { "<leader>dj", function() require("dap").down() end, desc = "下栈帧" },
      { "<leader>dk", function() require("dap").up() end, desc = "上栈帧" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "运行最后的配置" },
      { "<leader>do", function() require("dap").step_out() end, desc = "单步跳出" },
      { "<leader>dO", function() require("dap").step_over() end, desc = "单步跳过" },
      { "<leader>dp", function() require("dap").pause() end, desc = "暂停执行" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "切换 REPL" },
      { "<leader>ds", function() require("dap").session() end, desc = "获取会话" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "终止调试" },
      { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "小部件" },
    },
    config = function()
      local icons = {
        dap = {
          Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
          Breakpoint = " ",
          BreakpointCondition = " ",
          BreakpointRejected = { " ", "DiagnosticError" },
          LogPoint = ".>",
        },
      }
      
      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
      
      for name, sign in pairs(icons.dap) do
        sign = type(sign) == "table" and sign or { sign }
        vim.fn.sign_define(
          "Dap" .. name,
          { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
        )
      end
    end,
  },
  
  -- 问题检测器
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    opts = {
      use_diagnostic_signs = true,
      action_keys = {
        close = "q",
        cancel = "<esc>",
        refresh = "r",
        jump = { "<cr>", "<tab>", "<2-leftmouse>" },
        open_split = { "<c-s>" },
        open_vsplit = { "<c-v>" },
        open_tab = { "<c-t>" },
        jump_close = { "o" },
        toggle_mode = "m",
        switch_severity = "s",
        toggle_preview = "P",
        hover = "K",
        preview = "p",
        close_folds = { "zM", "zm" },
        open_folds = { "zR", "zr" },
        toggle_fold = { "zA", "za" },
        previous = "k",
        next = "j",
        help = "?",
      },
    },
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "文档诊断" },
      { "<leader>xX", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "工作区诊断" },
      { "<leader>xL", "<cmd>TroubleToggle loclist<cr>", desc = "位置列表" },
      { "<leader>xQ", "<cmd>TroubleToggle quickfix<cr>", desc = "快速修复" },
      {
        "[q",
        function()
          if require("trouble").is_open() then
            require("trouble").previous({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cprev)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = "上一个问题",
      },
      {
        "]q",
        function()
          if require("trouble").is_open() then
            require("trouble").next({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cnext)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = "下一个问题",
      },
    },
  },
} 