-- editor.lua - 编辑器增强插件配置

return {
  -- LazyGit 集成
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "打开 LazyGit" },
      { "<leader>gf", "<cmd>LazyGitCurrentFile<cr>", desc = "当前文件 Git 历史" },
      { "<leader>gc", "<cmd>LazyGitConfig<cr>", desc = "LazyGit 配置" },
    },
  },

  -- 模糊搜索
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
      -- 文件查找
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "查找文件" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "最近文件" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "查找缓冲区" },
      
      -- 内容搜索
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "全局搜索" },
      { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "搜索当前单词" },
      
      -- 其他功能
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "帮助标签" },
      { "<leader>fm", "<cmd>Telescope marks<cr>", desc = "跳转到书签" },
      { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "命令" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "快捷键" },
      
      -- 工作区相关
      { "<leader>ws", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "工作区符号" },
      
      -- LSP 相关
      { "<leader>cs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "文档符号" },
      { "<leader>cr", "<cmd>Telescope lsp_references<cr>", desc = "引用" },
      { "<leader>ci", "<cmd>Telescope lsp_implementations<cr>", desc = "实现" },
      { "<leader>cd", "<cmd>Telescope lsp_definitions<cr>", desc = "定义" },
      { "<leader>ct", "<cmd>Telescope lsp_type_definitions<cr>", desc = "类型定义" },
      
      -- 诊断
      { "<leader>xx", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "当前文件诊断" },
      { "<leader>xw", "<cmd>Telescope diagnostics<cr>", desc = "工作区诊断" },
    },
    opts = {
      defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        mappings = {
          i = {
            ["<C-j>"] = function(...)
              return require("telescope.actions").move_selection_next(...)
            end,
            ["<C-k>"] = function(...)
              return require("telescope.actions").move_selection_previous(...)
            end,
            ["<C-n>"] = function(...)
              return require("telescope.actions").cycle_history_next(...)
            end,
            ["<C-p>"] = function(...)
              return require("telescope.actions").cycle_history_prev(...)
            end,
            ["<C-c>"] = function(...)
              return require("telescope.actions").close(...)
            end,
            ["<C-u>"] = function(...)
              return require("telescope.actions").preview_scrolling_up(...)
            end,
            ["<C-d>"] = function(...)
              return require("telescope.actions").preview_scrolling_down(...)
            end,
          },
          n = {
            ["q"] = function(...)
              return require("telescope.actions").close(...)
            end,
          },
        },
      },
      pickers = {
        find_files = {
          -- 默认包含隐藏文件
          find_command = { "rg", "--files", "--hidden", "--glob", "!.git" },
        },
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      
      -- 加载扩展
      pcall(telescope.load_extension, "fzf")
    end,
  },
  
  -- LazyGit 集成
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "打开 LazyGit" },
      { "<leader>gf", "<cmd>LazyGitCurrentFile<cr>", desc = "当前文件 Git 历史" },
      { "<leader>gc", "<cmd>LazyGitConfig<cr>", desc = "LazyGit 配置" },
    },
  },

  -- 高级语法高亮
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    opts = {
      -- 自动安装的语法
      ensure_installed = {
        "bash",
        "c",
        "cmake",
        "comment",
        "cpp",
        "css",
        "dockerfile",
        "gitignore",
        "go",
        "gomod",
        "gowork",
        "html",
        "http",
        "java",
        "javascript",
        "json",
        "kotlin",
        "lua",
        "make",
        "markdown",
        "markdown_inline",
        "python",
        "regex",
        "ruby",
        "rust",
        "sql",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },
      
      -- 启用特性
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
      
      -- 文本对象
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
          },
          goto_next_end = {
            ["]F"] = "@function.outer",
            ["]C"] = "@class.outer",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
          },
          goto_previous_end = {
            ["[F"] = "@function.outer",
            ["[C"] = "@class.outer",
          },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  
  -- 代码注释
  {
    "numToStr/Comment.nvim",
    opts = {
      padding = true,  -- 在注释分隔符后添加空格
      sticky = true,   -- 注释时光标不移动
      toggler = {
        line = "gcc",  -- 行注释切换
        block = "gbc", -- 块注释切换
      },
      opleader = {
        line = "gc",   -- 行注释操作
        block = "gb",  -- 块注释操作
      },
      extra = {
        above = "gcO", -- 在当前行上方添加注释
        below = "gco", -- 在当前行下方添加注释
        eol = "gcA",   -- 在当前行尾添加注释
      },
      mappings = {
        basic = true,  -- 基本映射
        extra = true,  -- 额外映射
      },
    },
    keys = {
      { "gcc", mode = "n", desc = "行注释" },
      { "gbc", mode = "n", desc = "块注释" },
      { "gc", mode = { "n", "o" }, desc = "行注释操作" },
      { "gb", mode = { "n", "o" }, desc = "块注释操作" },
    },
  },
  
  -- 代码折叠
  {
    "kevinhwang91/nvim-ufo",
    dependencies = {
      "kevinhwang91/promise-async",
      {
        "luukvbaal/statuscol.nvim",
        config = function()
          local builtin = require("statuscol.builtin")
          require("statuscol").setup({
            relculright = true,
            segments = {
              { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
              { text = { "%s" }, click = "v:lua.ScSa" },
              { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
            },
          })
        end,
      },
    },
    event = "BufReadPost",
    opts = {
      provider_selector = function()
        return { "treesitter", "indent" }
      end,
      open_fold_hl_timeout = 150,
      close_fold_kinds_for_ft = {
        default = { "imports", "comment" },
        json = { "array" },
        yaml = { "sequence" },
      },
      preview = {
        win_config = {
          border = { "", "─", "", "", "", "─", "", "" },
          winhighlight = "Normal:Folded",
          winblend = 0,
        },
        mappings = {
          scrollU = "<C-u>",
          scrollD = "<C-d>",
          jumpTop = "[",
          jumpBot = "]",
        },
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
      { "zr", function() require("ufo").openFoldsExceptKinds() end, desc = "打开一级折叠" },
      { "zm", function() require("ufo").closeFoldsWith() end, desc = "关闭一级折叠" },
      { "zp", function() require("ufo").peekFoldedLinesUnderCursor() end, desc = "预览当前折叠" },
    },
  },
  
  -- 终端集成
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "浮动终端" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "水平终端" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical size=40<cr>", desc = "垂直终端" },
      { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "切换终端" },
    },
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_filetypes = {},
      autochdir = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      persist_mode = true,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        winblend = 3,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
    },
  },
  
  -- 代码片段
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
    keys = {
      {
        "<tab>",
        function()
          return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
        end,
        expr = true, silent = true, mode = "i",
      },
      { "<tab>", function() require("luasnip").jump(1) end, mode = "s" },
      { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
    },
  },
  
  -- 自动括号配对
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,  -- 检查 treesitter
      ts_config = {
        lua = { "string", "source" },
        javascript = { "string", "template_string" },
        java = false,
      },
      fast_wrap = {
        map = "<M-e>",
        chars = { "{", "[", "(", '"', "'" },
        pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
        offset = 0,
        end_key = "$",
        keys = "qwertyuiopzxcvbnmasdfghjkl",
        check_comma = true,
        highlight = "PmenuSel",
        highlight_grey = "LineNr",
      },
    },
  },
  
  -- Git 集成
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "▁" },
        topdelete = { text = "▔" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns
        
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end
        
        -- 导航
        map("n", "]h", gs.next_hunk, "下一个变更")
        map("n", "[h", gs.prev_hunk, "上一个变更")
        
        -- 操作
        map({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>", "暂存变更")
        map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", "重置变更")
        map("n", "<leader>gS", gs.stage_buffer, "暂存文件")
        map("n", "<leader>gu", gs.undo_stage_hunk, "取消暂存变更")
        map("n", "<leader>gR", gs.reset_buffer, "重置文件")
        map("n", "<leader>gp", gs.preview_hunk, "预览变更")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "查看责任")
        map("n", "<leader>gB", gs.toggle_current_line_blame, "开关行责任")
        map("n", "<leader>gd", gs.diffthis, "文件差异")
        map("n", "<leader>gD", function() gs.diffthis("~") end, "与HEAD差异")
        map("n", "<leader>gt", gs.toggle_deleted, "开关显示删除")
        
        -- 文本对象
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "选择变更")
      end,
    },
  },
  
  -- 多光标编辑
  {
    "mg979/vim-visual-multi",
    event = "BufReadPost",
    init = function()
      vim.g.VM_leader = ";"
      vim.g.VM_maps = {
        ["Find Under"] = "<C-d>",
        ["Find Subword Under"] = "<C-d>",
      }
    end,
  },
  
  -- 高亮相同单词
  {
    "RRethy/vim-illuminate",
    event = "BufReadPost",
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { "lsp" },
      },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)
      
      local function map(key, dir, buffer)
        vim.keymap.set("n", key, function()
          require("illuminate")["goto_" .. dir .. "_reference"](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " 引用", buffer = buffer })
      end
      
      -- 下一个/上一个引用导航
      map("]]", "next")
      map("[[", "prev")
      
      -- 同时也是 LSP 附加时设置键绑定
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local buffer = args.buf
          map("]]", "next", buffer)
          map("[[", "prev", buffer)
        end,
      })
    end,
    keys = {
      { "]]", desc = "下一个引用" },
      { "[[", desc = "上一个引用" },
    },
  },
  
  -- 缓冲区删除
  {
    "echasnovski/mini.bufremove",
    keys = {
      { "<leader>bd", function() require("mini.bufremove").delete(0, false) end, desc = "删除缓冲区" },
      { "<leader>bD", function() require("mini.bufremove").delete(0, true) end, desc = "强制删除缓冲区" },
    },
  },
  
  -- 括号高亮配对
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufReadPost",
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")
      
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },
} 