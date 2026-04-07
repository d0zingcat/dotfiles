-- lang/python.lua - Python 开发专用配置

return {
  -- 虚拟环境选择器
  {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp",
    cmd = "VenvSelect",
    ft = "python",
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
    opts = {
      settings = {
        options = {
          notify_user_on_venv_activation = true,
        },
      },
    },
    keys = {
      { "<leader>pv", "<cmd>VenvSelect<cr>", ft = "python", desc = "选择虚拟环境" },
    },
  },

  -- Python DAP 支持
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local ok, mason_registry = pcall(require, "mason-registry")
      local python_path = "python3"
      if ok and mason_registry.is_installed("debugpy") then
        python_path = mason_registry.get_package("debugpy"):get_install_path() .. "/venv/bin/python"
      end
      require("dap-python").setup(python_path)
      require("dap-python").test_runner = "pytest"

      -- 带参数启动
      table.insert(require("dap").configurations.python, {
        type = "python", request = "launch",
        name = "带参数启动",
        program = "${file}",
        args = function()
          return vim.split(vim.fn.input("命令行参数: "), " ")
        end,
        console = "integratedTerminal",
      })
    end,
    keys = {
      { "<leader>dpm", function() require("dap-python").test_method() end, ft = "python", desc = "调试当前方法" },
      { "<leader>dpc", function() require("dap-python").test_class() end, ft = "python", desc = "调试当前类" },
    },
  },

  -- neotest Python 适配器
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = { "nvim-neotest/neotest-python" },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      table.insert(opts.adapters, require("neotest-python")({
        runner = "pytest",
        args = { "--color=yes", "-v" },
        python = function()
          if vim.env.VIRTUAL_ENV then
            return vim.env.VIRTUAL_ENV .. "/bin/python"
          end
          return "python3"
        end,
      }))
      return opts
    end,
    keys = {
      { "<leader>pt",  function() require("neotest").run.run() end, ft = "python", desc = "运行最近测试" },
      { "<leader>pT",  function() require("neotest").run.run(vim.fn.expand("%")) end, ft = "python", desc = "运行文件测试" },
      { "<leader>pd",  function() require("neotest").run.run({ strategy = "dap" }) end, ft = "python", desc = "调试测试" },
      { "<leader>ps",  function() require("neotest").run.stop() end, ft = "python", desc = "停止测试" },
      { "<leader>po",  function() require("neotest").output.open() end, ft = "python", desc = "测试输出" },
      { "<leader>pO",  function() require("neotest").output_panel.toggle() end, ft = "python", desc = "输出面板" },
      { "<leader>pS",  function() require("neotest").summary.toggle() end, ft = "python", desc = "摘要窗口" },
    },
  },

  -- Mason Python 工具
  {
    "williamboman/mason.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "pyright", "ruff", "isort", "debugpy",
      })
    end,
  },
}
