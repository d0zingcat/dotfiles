-- python.lua - Python 开发专用配置

return {
  -- Python 专用插件
  {
    "linux-cultist/venv-selector.nvim",
    cmd = "VenvSelect",
    keys = {
      { "<leader>pv", "<cmd>VenvSelect<cr>", desc = "选择 Python 虚拟环境" },
      { "<leader>pc", "<cmd>VenvSelectCached<cr>", desc = "选择缓存的虚拟环境" },
    },
    opts = {
      name = {
        "venv",
        ".venv",
        "env",
        ".env",
        "virtualenv",
      },
      auto_refresh = true,
      search_from = "root", -- 从项目根目录搜索
    },
    config = function(_, opts)
      require("venv-selector").setup(opts)
      
      -- 自动激活虚拟环境
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = { "*.py" },
        callback = function()
          -- 使用缓存的 venv
          require("venv-selector").retrieve_from_cache()
        end,
      })
    end,
  },
  
  -- Python 单元测试插件
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "nvim-neotest/neotest-python",
    },
    opts = {
      adapters = {
        ["neotest-python"] = {
          -- 使用项目根目录中的 pytest.ini
          runner = "pytest",
          -- 可以使用 pytest 或 unittest
          -- runner = function()
          --   if vim.fn.filereadable("pytest.ini") == 1 then
          --     return "pytest"
          --   else
          --     return "unittest"
          --   end
          -- end,
          
          -- 额外的 pytest 参数
          args = {
            "--color=yes",
            "-v",
          },
          
          -- Python 测试发现模式
          python = function()
            -- 如果激活了虚拟环境，使用它
            if vim.env.VIRTUAL_ENV then
              return vim.env.VIRTUAL_ENV .. "/bin/python"
            end
            
            -- 否则使用系统的 Python
            return "python"
          end,
        },
      },
    },
    keys = {
      { "<leader>pt", "<cmd>lua require('neotest').run.run()<cr>", desc = "运行最近的测试" },
      { "<leader>pT", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", desc = "运行文件中的测试" },
      { "<leader>pd", "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>", desc = "调试最近的测试" },
      { "<leader>ps", "<cmd>lua require('neotest').run.stop()<cr>", desc = "停止测试" },
      { "<leader>pa", "<cmd>lua require('neotest').run.attach()<cr>", desc = "附加到测试" },
      { "<leader>po", "<cmd>lua require('neotest').output.open()<cr>", desc = "查看测试输出" },
      { "<leader>pO", "<cmd>lua require('neotest').output_panel.toggle()<cr>", desc = "切换输出面板" },
      { "<leader>pS", "<cmd>lua require('neotest').summary.toggle()<cr>", desc = "切换摘要窗口" },
    },
  },
  
  -- Python 导入排序和格式化
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        python = { "isort", "black" },
      },
      formatters = {
        black = {
          args = { "--line-length", "88", "--fast", "-" },
        },
        isort = {
          args = { "--stdout", "--profile", "black", "--line-length", "88", "-" },
        },
      },
    },
  },
  
  -- Python 调试
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      "mfussenegger/nvim-dap-python",
    },
    opts = function()
      local path = require("mason-registry").get_package("debugpy"):get_install_path()
      require("dap-python").setup(path .. "/venv/bin/python")
      
      -- 设置 pytest 调试
      require("dap-python").test_runner = "pytest"
      
      -- 添加自定义配置
      table.insert(require("dap").configurations.python, {
        type = "python",
        request = "launch",
        name = "启动带参数的文件",
        program = "${file}",
        args = function()
          local args_string = vim.fn.input("命令行参数: ")
          return vim.split(args_string, " ")
        end,
        console = "integratedTerminal",
      })
      
      -- 添加 FastAPI 配置
      table.insert(require("dap").configurations.python, {
        type = "python",
        request = "launch",
        name = "FastAPI",
        module = "uvicorn",
        args = function()
          local args = vim.fn.input("uvicorn 参数 (例如 main:app --reload): ")
          return vim.split(args, " ")
        end,
        console = "integratedTerminal",
      })
    end,
    keys = {
      -- Python 特定调试键
      { "<leader>dpr", function() require("dap-python").test_method() end, desc = "调试当前方法" },
      { "<leader>dpc", function() require("dap-python").test_class() end, desc = "调试当前类" },
      { "<leader>dpf", function() require("dap-python").test_method() end, desc = "调试当前函数" },
    },
  },
  
  -- Python 代码格式化和排序
  {
    "williamboman/mason.nvim",
    optional = true,
    opts = function(_, opts)
      -- 将额外的 Python 工具添加到确保安装列表中
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "black",
          "isort",
          "mypy",
          "ruff",
          "ruff-lsp",
          "pyright",
          "debugpy",
        })
      end
    end,
  },
  
  -- 代码折叠
  {
    "kevinhwang91/nvim-ufo",
    optional = true,
    opts = {
      close_fold_kinds_for_ft = {
        python = { "imports", "comment" },
      },
    },
  },
  
  -- REPL 集成
  {
    "michaelb/sniprun",
    build = "sh ./install.sh",
    cmd = { "SnipRun", "SnipInfo", "SnipReset", "SnipClose" },
    keys = {
      { "<leader>pe", "<cmd>SnipRun<cr>", desc = "执行选中代码", mode = { "n", "v" } },
      { "<leader>pE", "<cmd>SnipInfo<cr>", desc = "Sniprun 信息" },
    },
    opts = {
      display = { "NvimNotify" },
      interpreter_options = {
        Python3_fifo = {
          venv = function()
            return vim.env.VIRTUAL_ENV
          end,
          cwd = function()
            return vim.fn.getcwd()
          end,
        },
      },
    },
    config = function(_, opts)
      require("sniprun").setup(opts)
    end,
  },
} 