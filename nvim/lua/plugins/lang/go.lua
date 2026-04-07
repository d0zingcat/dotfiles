-- lang/go.lua - Go 开发专用配置

return {
  -- ray-x/go.nvim - Go 全功能插件
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "go", "gomod", "gowork", "gotmpl" },
    build = ':lua require("go.install").update_all_sync()',
    opts = {
      lsp_cfg = false, -- LSP 由 lsp.lua 的 gopls 配置统一管理
      lsp_keymaps = false,
      lsp_codelens = true,
      lsp_inlay_hints = {
        enable = true,
        only_current_line = false,
        show_parameter_hints = true,
        parameter_hints_prefix = " ",
        other_hints_prefix = " ",
      },
      formatter = "gofumpt",
      goimport = "gopls",
      gofmt = true,
      test_runner = "go",
      run_in_floaterm = true,
      dap_debug = true,
      dap_debug_gui = true,
      dap_debug_vt = true,
      textobjects = true,
      trouble = true,
      diagnostic = {
        hdlr = true,
        underline = true,
        virtual_text = { space = 0, prefix = "" },
        signs = true,
        update_in_insert = false,
      },
      tag_transform = "snakecase",
      verbose = false,
    },
    config = function(_, opts)
      require("go").setup(opts)

      local gogroup = vim.api.nvim_create_augroup("GoGroup", { clear = true })

      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        group = gogroup,
        callback = function()
          require("go.format").goimport()
        end,
      })
    end,
    keys = {
      { "<leader>gts", "<cmd>GoAlt<cr>", ft = "go", desc = "切换测试/实现" },
      { "<leader>gtt", "<cmd>GoTest<cr>", ft = "go", desc = "运行测试" },
      { "<leader>gtf", "<cmd>GoTestFunc<cr>", ft = "go", desc = "测试当前函数" },
      { "<leader>gtc", "<cmd>GoCoverage<cr>", ft = "go", desc = "测试覆盖率" },
      { "<leader>gtC", "<cmd>GoCoverageClear<cr>", ft = "go", desc = "清除覆盖率" },
      { "<leader>gge", "<cmd>GoIfErr<cr>", ft = "go", desc = "生成错误处理" },
      { "<leader>ggf", "<cmd>GoFillStruct<cr>", ft = "go", desc = "填充结构体" },
      { "<leader>ggs", "<cmd>GoFillSwitch<cr>", ft = "go", desc = "填充 switch" },
      { "<leader>gta", "<cmd>GoAddTag<cr>", ft = "go", desc = "添加标签" },
      { "<leader>gtr", "<cmd>GoRmTag<cr>", ft = "go", desc = "移除标签" },
      { "<leader>gr",  "<cmd>GoRun<cr>", ft = "go", desc = "运行" },
      { "<leader>gb",  "<cmd>GoBuild<cr>", ft = "go", desc = "构建" },
      { "<leader>gi",  "<cmd>GoImpl<cr>", ft = "go", desc = "实现接口" },
      { "<leader>gdc", "<cmd>GoDoc<cr>", ft = "go", desc = "查看文档" },
      { "<leader>gv",  "<cmd>GoVet<cr>", ft = "go", desc = "go vet" },
    },
  },

  -- Go DAP 支持
  {
    "leoluz/nvim-dap-go",
    ft = "go",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-go").setup({ dap_configurations = {
        { type = "go", name = "调试文件", request = "launch", program = "${file}" },
        { type = "go", name = "调试包", request = "launch", program = "${fileDirname}" },
        { type = "go", name = "调试测试", request = "launch", mode = "test", program = "${file}" },
      }})
    end,
    keys = {
      { "<leader>dtg", function() require("dap-go").debug_test() end, ft = "go", desc = "调试当前测试" },
      { "<leader>dtl", function() require("dap-go").debug_last_test() end, ft = "go", desc = "调试上次测试" },
    },
  },

  -- neotest Go 适配器
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = { "nvim-neotest/neotest-go" },
    opts = {
      adapters = {
        ["neotest-go"] = {
          args = { "-count=1", "-timeout=30s", "-v" },
        },
      },
    },
  },

  -- Mason Go 工具
  {
    "williamboman/mason.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "gopls", "gofumpt", "goimports", "golangci-lint",
        "gomodifytags", "gotests", "impl", "delve",
      })
    end,
  },
}
