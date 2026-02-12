-- avante.lua - AI 编程助手，类似 Cursor 的体验
-- 基于 OpenAI/Anthropic API 提供智能代码编辑

return {
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		version = false, -- 使用最新版本
		build = "make", -- 构建依赖
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			-- 可选: 用于图片粘贴支持
			"HakonHarnes/img-clip.nvim",
		},
		opts = {
			-- 默认 AI 提供商
			provider = "openai",

			-- 提供商配置 (v0.46+ 版本结构)
			providers = {
				-- OpenAI 配置
				openai = {
					endpoint = "https://api.openai.com/v1",
					model = "gpt-4o",
					timeout = 30000,
					context_window = 128000,
					extra_request_body = {
						temperature = 0.75,
						max_completion_tokens = 16384,
						reasoning_effort = "medium",
					},
				},

				-- Anthropic Claude 配置（备选）
				claude = {
					endpoint = "https://api.anthropic.com",
					model = "claude-3-5-sonnet-20241022",
					timeout = 30000,
					context_window = 200000,
					extra_request_body = {
						temperature = 0.75,
						max_completion_tokens = 8192,
					},
				},

				-- Azure OpenAI 配置（企业用户）
				azure = {
					endpoint = "", -- 你的 Azure 端点，例如: https://<resource>.openai.azure.com
					deployment = "", -- 部署名称
					api_version = "2024-12-01-preview",
					timeout = 30000,
					context_window = 128000,
					extra_request_body = {
						temperature = 0.75,
						max_completion_tokens = 16384,
						reasoning_effort = "medium",
					},
				},

				-- Copilot 配置（可选）
				copilot = {
					endpoint = "https://api.githubcopilot.com",
					model = "gpt-4o-copilot",
					timeout = 30000,
					context_window = 128000,
					extra_request_body = {
						temperature = 0.75,
						max_completion_tokens = 16384,
					},
				},
			},

			-- 系统提示词 - 定义 AI 助手的角色
			system_prompt = [[
You are an expert coding assistant. Your task is to help users write, refactor, and understand code.

Rules:
1. Always respond with code changes in the specified format
2. Explain your changes clearly
3. Consider code style and best practices
4. If unsure, ask clarifying questions
5. Be concise but thorough

When suggesting code changes:
- Use the diff format if replacing existing code
- Ensure code is syntactically correct
- Follow the existing code style of the project
]],

			-- 浮动窗口样式
			windows = {
				---@type "right" | "left" | "top" | "bottom"
				position = "right",
				wrap = true,
				width = 40,
				sidebar_header = {
					align = "center",
					rounded = true,
				},
			},

			-- 高亮配置
			highlights = {
				diff = {
					current = "DiffText",
					incoming = "DiffAdd",
				},
			},

			-- 差异视图配置
			diff = {
				autojump = true,
				list_opener = function()
					-- 可以自定义差异列表打开方式
					vim.cmd("copen")
				end,
			},

			-- 建议 Provider 配置（用于代码补全）
			suggestion_provider = "copilot", -- 或 "default"

			-- 上下文窗口配置
			context_window = 6000,

			-- 行为配置
			behaviour = {
				-- 是否自动应用建议
				auto_apply_suggestion_after_generation = false,
				-- 是否支持图片粘贴
				support_paste_from_clipboard = false,
			},

			-- 映射配置（空表示使用默认映射）
			mappings = {
				-- 默认映射:
				-- <leader>aa - 打开侧边栏
				-- <leader>ar - 重置对话
				-- <leader>af - 切换焦点
				-- <leader>ae - 编辑请求
				-- <leader>as - 切换侧边栏位置
				-- <leader>at - 停止生成
			},
		},
		keys = {
			-- 打开 AI 侧边栏
			{
				"<leader>aa",
				function()
					require("avante").toggle()
				end,
				desc = "AI 助手 (avante)",
				mode = { "n", "v" },
			},
			-- 重置对话
			{
				"<leader>ar",
				function()
					require("avante").reset()
				end,
				desc = "重置 AI 对话",
			},
			-- 快速询问（选中代码）
			{
				"<leader>ai",
				function()
					require("avante").ask()
				end,
				desc = "AI 询问选中的代码",
				mode = "v",
			},
			-- 编辑代码
			{
				"<leader>ae",
				function()
					require("avante").edit()
				end,
				desc = "AI 编辑代码",
				mode = "v",
			},
		},
	},
	-- 可选依赖: 图片粘贴支持
	{
		"HakonHarnes/img-clip.nvim",
		event = "VeryLazy",
		opts = {
			-- 默认配置即可
			default = {
				embed_image_as_base64 = false,
				prompt_for_file_name = false,
				drag_and_drop = {
					insert_mode = true,
				},
			},
		},
	},
}
