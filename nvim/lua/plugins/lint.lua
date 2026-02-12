-- lint.lua - 代码检查配置
-- 使用 nvim-lint 替代 null-ls 的诊断功能
-- 与 conform.nvim 配合：conform 负责格式化，lint 负责诊断

return {
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")

			-- 按文件类型配置 linter
			lint.linters_by_ft = {
				-- Python: 使用 ruff 替代 flake8/pylint
				python = { "ruff" },

				-- Lua
				lua = { "luacheck" },

				-- Go
				go = { "golangcilint" },

				-- JavaScript/TypeScript
				javascript = { "eslint" },
				typescript = { "eslint" },
				javascriptreact = { "eslint" },
				typescriptreact = { "eslint" },

				-- 通用
				markdown = { "markdownlint" },
				yaml = { "yamllint" },
				dockerfile = { "hadolint" },
				sh = { "shellcheck" },
			}

			-- 设置自动触发
			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

			-- 保存后检查
			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
				group = lint_augroup,
				callback = function()
					lint.try_lint()
				end,
			})

			-- 进入缓冲区时检查
			vim.api.nvim_create_autocmd({ "BufEnter" }, {
				group = lint_augroup,
				callback = function()
					lint.try_lint()
				end,
			})

			-- 插入模式离开后检查（可选，可能较频繁）
			vim.api.nvim_create_autocmd({ "InsertLeave" }, {
				group = lint_augroup,
				callback = function()
					lint.try_lint()
				end,
			})

			-- 创建用户命令
			vim.api.nvim_create_user_command("Lint", function()
				lint.try_lint()
			end, { desc = "手动触发代码检查" })

			vim.api.nvim_create_user_command("LintInfo", function()
				local running_linters = lint.get_running()
				if #running_linters == 0 then
					vim.notify("没有正在运行的 linter", vim.log.levels.INFO)
				else
					vim.notify("运行中的 linter: " .. table.concat(running_linters, ", "), vim.log.levels.INFO)
				end
			end, { desc = "显示运行中的 linter" })
		end,
	},
}
