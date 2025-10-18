-- go.lua - Go 开发专用配置

return {
  -- Go 专用插件
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "go", "gomod", "gowork", "gotmpl" },
    build = ':lua require("go.install").update_all_sync()', -- 同步更新所有解析器
    opts = {
      -- 日志级别: 可以是 'trace', 'debug', 'info', 'warn', 'error', 'fatal'
      lsp_cfg = {
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
      lsp_on_attach = function(client, bufnr)
        -- 启用自动格式化
        vim.api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr()")
        
        -- 设置键映射
        local map = function(mode, lhs, rhs, desc)
          if desc then
            desc = desc
          end
          vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc, buffer = bufnr, noremap = true })
        end
        
        -- Go 特定映射
        map("n", "<leader>gfs", "<cmd>GoFillStruct<cr>", "填充结构体")
        map("n", "<leader>gfa", "<cmd>GoAddTag<cr>", "添加标签")
        map("n", "<leader>gfr", "<cmd>GoRmTag<cr>", "移除标签")
        map("n", "<leader>gcl", "<cmd>GoClearTag<cr>", "清除标签")
        map("n", "<leader>ge", "<cmd>GoIfErr<cr>", "生成错误处理")
        
        -- 代码生成
        map("n", "<leader>ggt", "<cmd>GoTest<cr>", "生成测试")
        map("n", "<leader>ggf", "<cmd>GoTestFunc<cr>", "生成函数测试")
        map("n", "<leader>ggc", "<cmd>GoCoverage<cr>", "显示测试覆盖率")
        map("n", "<leader>ggC", "<cmd>GoCoverageClear<cr>", "清除测试覆盖率")
        map("n", "<leader>ggb", "<cmd>GoBuild<cr>", "构建")
        map("n", "<leader>ggr", "<cmd>GoRun<cr>", "运行")
        
        -- 代码操作
        map("n", "<leader>gil", "<cmd>GoImport<cr>", "导入包")
        map("n", "<leader>gia", "<cmd>GoImportAll<cr>", "导入所有")
        map("n", "<leader>gif", "<cmd>GoImpl<cr>", "实现接口")
        map("n", "<leader>gid", "<cmd>GoDoc<cr>", "查看文档")
        
        -- 代码移动
        map("n", "<leader>gca", "<cmd>GoCodeAction<cr>", "代码操作")
        map("n", "<leader>gfd", "<cmd>GoFixDocumentation<cr>", "修复文档")
        map("n", "<leader>gsf", "<cmd>GoFillSwitch<cr>", "填充 switch")
        map("n", "<leader>gsj", "<cmd>GoAddErrCheck<cr>", "添加错误检查")
        
        -- 调试和测试
        map("n", "<leader>gtc", "<cmd>GoCmt<cr>", "生成注释")
        map("n", "<leader>gts", "<cmd>GoAlt<cr>", "在实现和测试间切换")
      end,
      lsp_codelens = true,
      -- 控制 gopls 设置
      lsp_keymaps = false, -- 我们手动设置键映射
      lsp_diag_hdlr = true,
      lsp_diag_virtual_text = { space = 0, prefix = "" },
      lsp_diag_signs = true,
      lsp_diag_update_in_insert = false,
      lsp_document_formatting = true,
      -- 代码格式化设置
      formatter = "gofumpt", -- gofmt, gofumpt, golines
      formatter_extra_args = { "-s" },
      -- 测试设置
      test_runner = "go", -- richgo, go test, richgo, dlv, ginkgo
      run_in_floaterm = true,
      -- 调试设置
      dap_debug = true,
      dap_debug_gui = true,
      dap_debug_vt = true,
      dap_port = 38697,
      dap_timeout = 15,
      -- 其他设置
      textobjects = true,
      gofmt = true, -- 设置 gofmt 和 goimports
      goimport = "gopls", -- goimport, gopls
      diagnostic = {
        hdlr = true,
        underline = true,
        virtual_text = { space = 0, prefix = "" },
        signs = true,
        update_in_insert = false,
      },
      tag_transform = "snakecase",
      -- 路径设置
      verbose = false,
      trouble = true,
      lsp_inlay_hints = {
        enable = true,
        -- 使用 LSP 内联提示而不是 virtualtypes
        only_current_line = false,
        only_current_line_autocmd = "CursorHold",
        show_parameter_hints = true,
        show_variable_name = true,
        parameter_hints_prefix = " ",
        other_hints_prefix = " ",
        highlight = "LspInlayHint",
      },
    },
    config = function(_, opts)
      require("go").setup(opts)
      
      -- 设置自动命令
      local gogroup = vim.api.nvim_create_augroup("GoGroup", { clear = true })
      
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        group = gogroup,
        callback = function()
          require("go.format").goimport()
        end,
      })
      
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "go",
        group = gogroup,
        callback = function()
          -- 将 tab 宽度设置为 Go 的标准
          vim.bo.tabstop = 4
          vim.bo.shiftwidth = 4
          vim.bo.softtabstop = 4
          vim.bo.expandtab = false
        end,
      })
    end,
    keys = {
      -- 测试
      { "<leader>gts", "<cmd>GoAlt<cr>", desc = "切换测试/实现文件" },
      { "<leader>gtt", "<cmd>GoTest<cr>", desc = "运行包测试" },
      { "<leader>gtf", "<cmd>GoTestFunc<cr>", desc = "测试函数" },
      { "<leader>gtc", "<cmd>GoCoverage<cr>", desc = "测试覆盖率" },
      { "<leader>gtC", "<cmd>GoCoverageClear<cr>", desc = "清除测试覆盖率" },
      
      -- 格式化
      { "<leader>gff", "<cmd>GoFormat<cr>", desc = "格式化" },
      { "<leader>gfi", "<cmd>GoImport<cr>", desc = "导入" },
      { "<leader>gfI", "<cmd>GoImportAll<cr>", desc = "导入所有" },
      
      -- 模板
      { "<leader>gge", "<cmd>GoIfErr<cr>", desc = "生成错误处理" },
      { "<leader>ggf", "<cmd>GoFillStruct<cr>", desc = "填充结构体" },
      { "<leader>ggs", "<cmd>GoFillSwitch<cr>", desc = "填充 switch" },
      
      -- 标签
      { "<leader>gta", "<cmd>GoAddTag<cr>", desc = "添加标签" },
      { "<leader>gtr", "<cmd>GoRmTag<cr>", desc = "移除标签" },
      { "<leader>gtc", "<cmd>GoClearTag<cr>", desc = "清除标签" },
      
      -- 运行和构建
      { "<leader>gr", "<cmd>GoRun<cr>", desc = "运行" },
      { "<leader>gb", "<cmd>GoBuild<cr>", desc = "构建" },
      
      -- 工具
      { "<leader>gi", "<cmd>GoImpl<cr>", desc = "实现接口" },
      { "<leader>gd", "<cmd>GoDoc<cr>", desc = "查看文档" },
      { "<leader>gl", "<cmd>GoLint<cr>", desc = "运行 golint" },
      { "<leader>gv", "<cmd>GoVet<cr>", desc = "运行 go vet" },
    },
  },
  
  -- 格式化集成
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        go = { "goimports", "gofumpt" },
      },
    },
  },
  
  -- 调试支持
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "leoluz/nvim-dap-go",
        config = true,
      },
    },
    keys = {
      { "<leader>dgr", function() require("dap-go").debug_test() end, desc = "调试当前测试" },
      { "<leader>dgl", function() require("dap-go").debug_last_test() end, desc = "调试上一个测试" },
    },
  },
  
  -- 单元测试
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "nvim-neotest/neotest-go",
    },
    opts = {
      adapters = {
        ["neotest-go"] = {
          -- 使用 gotest 作为测试器
          args = { "-count=1", "-timeout=30s", "-v" },
        },
      },
    },
  },
  
  -- 工具安装程序
  {
    "williamboman/mason.nvim",
    optional = true,
    opts = function(_, opts)
      -- 添加 Go 工具到确保安装列表
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "gopls",
          "gofumpt",
          "goimports",
          "golangci-lint",
          "gomodifytags",
          "gotests",
          "impl",
          "delve",
        })
      end
    end,
  },
  
  -- Treesitter 集成
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- 添加 Go 相关的解析器
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "go",
          "gomod",
          "gowork",
          "gosum",
        })
      end
    end,
  },
} 