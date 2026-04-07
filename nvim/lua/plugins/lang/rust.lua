-- lang/rust.lua - Rust 开发专用配置（rustaceanvim + codelldb）

return {
  -- rustaceanvim - Rust 全功能插件（接管 rust-analyzer LSP）
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    ft = "rust",
    opts = {
      server = {
        on_attach = function(_, bufnr)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
          end
          -- Rust 专用操作
          map("n", "<leader>rr", function() vim.cmd.RustLsp("runnables") end, "Rust 运行目标")
          map("n", "<leader>rt", function() vim.cmd.RustLsp("testables") end, "Rust 测试目标")
          map("n", "<leader>rd", function() vim.cmd.RustLsp("debuggables") end, "Rust 调试目标")
          map("n", "<leader>re", function() vim.cmd.RustLsp("explainError") end, "解释错误")
          map("n", "<leader>rc", function() vim.cmd.RustLsp("openCargo") end, "打开 Cargo.toml")
          map("n", "<leader>rp", function() vim.cmd.RustLsp("parentModule") end, "父模块")
          map("n", "<leader>rm", function() vim.cmd.RustLsp("expandMacro") end, "展开宏")
          map("n", "<leader>rx", function() vim.cmd.RustLsp("externalDocs") end, "外部文档")
          map("n", "K", function() vim.cmd.RustLsp({ "hover", "actions" }) end, "悬浮操作")
          map("n", "<leader>ca", function() vim.cmd.RustLsp("codeAction") end, "代码操作")
        end,
        default_settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              runBuildScripts = true,
            },
            checkOnSave = {
              allFeatures = true,
              command = "clippy",
              extraArgs = { "--no-deps" },
            },
            procMacro = {
              enable = true,
              ignored = {
                ["async-trait"] = { "async_trait" },
                ["napi-derive"] = { "napi" },
                ["async-recursion"] = { "async_recursion" },
              },
            },
            inlayHints = {
              bindingModeHints = { enable = false },
              chainingHints = { enable = true },
              closingBraceHints = { enable = true, minLines = 25 },
              closureReturnTypeHints = { enable = "never" },
              lifetimeElisionHints = { enable = "never" },
              parameterHints = { enable = false },
              typeHints = { enable = true, hideClosureInitialization = false, hideNamedConstructor = false },
            },
          },
        },
      },
      -- DAP 配置（codelldb）
      dap = {},
    },
    config = function(_, opts)
      -- 延迟设置 DAP adapter（需在 rustaceanvim 加载后才能 require）
      local ok_mason, mason_registry = pcall(require, "mason-registry")
      if ok_mason and mason_registry.is_installed("codelldb") then
        local codelldb_path = mason_registry.get_package("codelldb"):get_install_path()
        local codelldb = codelldb_path .. "/codelldb"
        local liblldb = codelldb_path .. "/extension/lldb/lib/liblldb.dylib"
        if vim.fn.has("linux") == 1 then
          liblldb = codelldb_path .. "/extension/lldb/lib/liblldb.so"
        end
        opts.dap = opts.dap or {}
        opts.dap.adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb, liblldb)
      end
      vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts)
    end,
  },

  -- crates.nvim - Cargo.toml 依赖管理
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      completion = {
        cmp = { enabled = false },
        crates = { enabled = true, max_results = 8, min_chars = 3 },
      },
      lsp = {
        enabled = true,
        on_attach = function() end,
        actions = true,
        completion = true,
        hover = true,
      },
    },
    keys = {
      { "<leader>rcu", function() require("crates").upgrade_all_crates() end, ft = "toml", desc = "升级所有依赖" },
      { "<leader>rco", function() require("crates").show_popup() end, ft = "toml", desc = "Crate 信息" },
    },
  },

  -- Mason Rust 工具
  {
    "williamboman/mason.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "codelldb" })
    end,
  },
}
