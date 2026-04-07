-- editor.lua - 编辑器增强插件配置
-- 包含：telescope, gitsigns, flash, todo-comments, which-key, mini.bufremove,
--       autopairs, illuminate, ufo(折叠), rainbow-delimiters, toggleterm,
--       trouble(v3), persistence, luasnip, ts-comments, vim-visual-multi

return {
  -- 模糊搜索（保留 telescope 作为备选/LSP 操作入口）
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        enabled = vim.fn.executable("make") == 1,
      },
    },
    keys = {
      { "<leader>fp", "<cmd>Telescope projects<cr>", desc = "项目" },
    },
    opts = {
      defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        mappings = {
          i = {
            ["<C-j>"] = function(...) return require("telescope.actions").move_selection_next(...) end,
            ["<C-k>"] = function(...) return require("telescope.actions").move_selection_previous(...) end,
            ["<C-c>"] = function(...) return require("telescope.actions").close(...) end,
          },
          n = { ["q"] = function(...) return require("telescope.actions").close(...) end },
        },
      },
      pickers = {
        find_files = { find_command = { "rg", "--files", "--hidden", "--glob", "!.git" } },
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
    end,
  },

  -- Git 变更标记
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" }, change = { text = "▎" }, delete = { text = "" },
        topdelete = { text = "" }, changedelete = { text = "▎" }, untracked = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end
        map("n", "]h", gs.next_hunk, "下一个变更")
        map("n", "[h", gs.prev_hunk, "上一个变更")
        map({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>", "暂存变更")
        map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", "重置变更")
        map("n", "<leader>gS", gs.stage_buffer, "暂存文件")
        map("n", "<leader>gu", gs.undo_stage_hunk, "取消暂存变更")
        map("n", "<leader>gR", gs.reset_buffer, "重置文件")
        map("n", "<leader>gp", gs.preview_hunk, "预览变更")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "查看责任")
        map("n", "<leader>gB", gs.toggle_current_line_blame, "开关行责任")
        map("n", "<leader>gd", gs.diffthis, "文件差异")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "选择变更")
      end,
    },
  },

  -- 快速跳转
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      search = { multi_window = false, wrap = true },
      modes = { char = { enabled = true, keys = { "f", "F", "t", "T", ";", "," } } },
    },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash 跳转" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Flash 远程" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Flash Treesitter 搜索" },
    },
  },

  -- TODO 注释高亮
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "BufReadPost",
    opts = { signs = true },
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "下一个 TODO" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "上一个 TODO" },
      { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "TODO 列表" },
    },
  },

  -- which-key 按键提示
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = {
        marks = true, registers = true,
        spelling = { enabled = true, suggestions = 20 },
        presets = { operators = true, motions = true, text_objects = true, windows = true, nav = true, z = true, g = true },
      },
      icons = { breadcrumb = "»", separator = "➜", group = "+" },
      win = { border = "rounded" },
      show_help = true,
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>b",  group = "缓冲区" },
        { "<leader>c",  group = "代码" },
        { "<leader>d",  group = "调试" },
        { "<leader>f",  group = "查找/文件" },
        { "<leader>g",  group = "Git" },
        { "<leader>n",  group = "通知" },
        { "<leader>q",  group = "退出/会话" },
        { "<leader>r",  group = "Rust" },
        { "<leader>s",  group = "搜索" },
        { "<leader>t",  group = "TypeScript/终端" },
        { "<leader>u",  group = "UI 切换" },
        { "<leader>x",  group = "诊断" },
        { "<leader>p",  group = "Python" },
        { "<leader>gt", group = "Go 测试" },
        { "<leader>gg", group = "Go 生成" },
        { "<leader>dt", group = "调试 - 测试" },
        { "<leader>dp", group = "调试 - Python" },
        { "<leader>rc", group = "Rust Crate" },
        { "<leader>sn", group = "Noice" },
      })
    end,
  },

  -- Trouble v3 - 诊断列表
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {
      modes = {
        lsp = {
          win = { position = "right" },
        },
      },
    },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "诊断" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "当前文件诊断" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "位置列表" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "快速修复" },
      { "<leader>xs", "<cmd>Trouble symbols toggle<cr>", desc = "符号" },
      {
        "[q",
        function()
          if require("trouble").is_open() then
            require("trouble").prev({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cprev)
            if not ok then vim.notify(err, vim.log.levels.ERROR) end
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
            if not ok then vim.notify(err, vim.log.levels.ERROR) end
          end
        end,
        desc = "下一个问题",
      },
    },
  },

  -- 缓冲区删除（保留分割窗口）
  {
    "echasnovski/mini.bufremove",
    keys = {
      { "<leader>bd", function() require("mini.bufremove").delete(0, false) end, desc = "关闭缓冲区" },
      { "<leader>bD", function() require("mini.bufremove").delete(0, true) end, desc = "强制关闭缓冲区" },
    },
  },

  -- 自动括号配对
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
      ts_config = {
        lua = { "string", "source" },
        javascript = { "string", "template_string" },
      },
      fast_wrap = { map = "<M-e>" },
    },
  },

  -- 高亮相同单词
  {
    "RRethy/vim-illuminate",
    event = "BufReadPost",
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = { providers = { "lsp" } },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)
      local function map(key, dir, buffer)
        vim.keymap.set("n", key, function()
          require("illuminate")["goto_" .. dir .. "_reference"](false)
        end, { desc = dir .. " 引用", buffer = buffer })
      end
      map("]]", "next")
      map("[[", "prev")
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          map("]]", "next", args.buf)
          map("[[", "prev", args.buf)
        end,
      })
    end,
    keys = { { "]]", desc = "下一个引用" }, { "[[", desc = "上一个引用" } },
  },

  -- 代码折叠（基于 LSP/treesitter）
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    opts = {
      provider_selector = function() return { "treesitter", "indent" } end,
      open_fold_hl_timeout = 150,
      preview = {
        win_config = { border = { "", "─", "", "", "", "─", "", "" }, winhighlight = "Normal:Folded", winblend = 0 },
        mappings = { scrollU = "<C-u>", scrollD = "<C-d>", jumpTop = "[", jumpBot = "]" },
      },
    },
    init = function()
      vim.o.foldcolumn = "0"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
    end,
    keys = {
      { "zR", function() require("ufo").openAllFolds() end, desc = "打开所有折叠" },
      { "zM", function() require("ufo").closeAllFolds() end, desc = "关闭所有折叠" },
      { "zr", function() require("ufo").openFoldsExceptKinds() end, desc = "展开一级" },
      { "zm", function() require("ufo").closeFoldsWith() end, desc = "折叠一级" },
      { "zp", function() require("ufo").peekFoldedLinesUnderCursor() end, desc = "预览折叠" },
    },
  },

  -- 彩虹括号
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufReadPost",
    config = function()
      local rd = require("rainbow-delimiters")
      vim.g.rainbow_delimiters = {
        strategy = { [""] = rd.strategy["global"], vim = rd.strategy["local"] },
        query = { [""] = "rainbow-delimiters", lua = "rainbow-blocks" },
        highlight = {
          "RainbowDelimiterRed", "RainbowDelimiterYellow", "RainbowDelimiterBlue",
          "RainbowDelimiterOrange", "RainbowDelimiterGreen", "RainbowDelimiterViolet", "RainbowDelimiterCyan",
        },
      }
    end,
  },

  -- 终端集成
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "浮动终端" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "水平终端" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical size=40<cr>", desc = "垂直终端" },
      { "<C-\\>", "<cmd>ToggleTerm<cr>", desc = "切换终端" },
    },
    opts = {
      size = function(term)
        if term.direction == "horizontal" then return 15
        elseif term.direction == "vertical" then return vim.o.columns * 0.4
        end
      end,
      open_mapping = [[<c-\>]],
      direction = "float",
      float_opts = { border = "curved", winblend = 3 },
      autochdir = true,
      start_in_insert = true,
      close_on_exit = true,
    },
  },

  -- 会话管理
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
      dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
      options = { "buffers", "curdir", "tabpages", "winsize" },
    },
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "恢复上次会话" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "恢复最后会话" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "不保存会话" },
    },
  },

  -- 多光标（<C-n> 选择当前词，<C-Down/Up> 添加光标）
  {
    "mg979/vim-visual-multi",
    event = "BufReadPost",
    init = function()
      vim.g.VM_leader = ";"
      -- 使用默认 <C-n> 而非覆盖 <C-d>（<C-d> 已用于滚动）
      vim.g.VM_maps = {
        ["Find Under"]         = "<C-n>",
        ["Find Subword Under"] = "<C-n>",
      }
    end,
  },

  -- TypeScript/JSX 注释增强
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    opts = { enable_autocmd = false },
  },

  -- 注释插件（支持 context commentstring）
  {
    "numToStr/Comment.nvim",
    event = "BufReadPost",
    opts = {
      padding = true,
      sticky = true,
      toggler = { line = "gcc", block = "gbc" },
      opleader = { line = "gc", block = "gb" },
      extra = { above = "gcO", below = "gco", eol = "gcA" },
      pre_hook = function()
        return require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook()()
      end,
    },
  },

  -- 增强文本对象（mini.ai）
  -- af/if=函数, ac/ic=类, aa/ia=参数, ab/ib=块, aq/iq=引号, at/it=标签
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = {
      n_lines = 500,
      custom_textobjects = {
        -- 整个文件
        e = function()
          local from = { line = 1, col = 1 }
          local to = { line = vim.fn.line("$"), col = math.max(vim.fn.getline("$"):len(), 1) }
          return { from = from, to = to }
        end,
      },
    },
  },

  -- 括号/引号包围操作（mini.surround）
  -- saiw" = 用 " 包围单词, sd" = 删除 ", sr"' = 替换 " 为 '
  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts = {
      mappings = {
        add            = "gsa",  -- 添加包围
        delete         = "gsd",  -- 删除包围
        find           = "gsf",  -- 向前查找包围
        find_left      = "gsF",  -- 向后查找包围
        highlight      = "gsh",  -- 高亮包围
        replace        = "gsr",  -- 替换包围
        update_n_lines = "gsn",  -- 更新搜索范围
      },
    },
  },

  -- 项目范围搜索替换（grug-far）
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
      {
        "<leader>sr",
        function()
          local ext = vim.bo.filetype ~= "" and ("." .. vim.bo.filetype) or ""
          require("grug-far").open({ prefills = { filesFilter = "*" .. ext } })
        end,
        mode = { "n", "v" },
        desc = "搜索替换（项目范围）",
      },
    },
    opts = { headerMaxWidth = 80 },
  },
}
