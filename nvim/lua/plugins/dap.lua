-- dap.lua - 调试适配器协议（通用配置）

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        opts = {
          icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
          layouts = {
            {
              elements = {
                { id = "scopes", size = 0.25 },
                { id = "breakpoints", size = 0.25 },
                { id = "stacks", size = 0.25 },
                { id = "watches", size = 0.25 },
              },
              size = 40,
              position = "left",
            },
            {
              elements = {
                { id = "repl", size = 0.5 },
                { id = "console", size = 0.5 },
              },
              size = 15,
              position = "bottom",
            },
          },
          floating = { border = "rounded" },
        },
        config = function(_, opts)
          local dap = require("dap")
          local dapui = require("dapui")
          dapui.setup(opts)
          dap.listeners.after.event_initialized["dapui_config"] = dapui.open
          dap.listeners.before.event_terminated["dapui_config"] = dapui.close
          dap.listeners.before.event_exited["dapui_config"] = dapui.close
        end,
      },
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = { commented = true },
      },
    },
    keys = {
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("断点条件: ")) end, desc = "条件断点" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "切换断点" },
      { "<leader>dc", function() require("dap").continue() end, desc = "继续/启动" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "运行到光标" },
      { "<leader>di", function() require("dap").step_into() end, desc = "单步进入" },
      { "<leader>do", function() require("dap").step_out() end, desc = "单步跳出" },
      { "<leader>dO", function() require("dap").step_over() end, desc = "单步跳过" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "重新运行" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "终止调试" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "REPL" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "调试 UI" },
      { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "悬浮变量" },
    },
    config = function()
      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
      local signs = {
        Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
        Breakpoint = " ",
        BreakpointCondition = " ",
        BreakpointRejected = { " ", "DiagnosticError" },
        LogPoint = ".>",
      }
      for name, sign in pairs(signs) do
        sign = type(sign) == "table" and sign or { sign }
        vim.fn.sign_define("Dap" .. name, {
          text = sign[1],
          texthl = sign[2] or "DiagnosticInfo",
          linehl = sign[3],
          numhl = sign[3],
        })
      end
    end,
  },
}
