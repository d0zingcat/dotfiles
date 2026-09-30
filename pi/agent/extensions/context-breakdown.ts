/**
 * Context Breakdown Extension
 *
 * Provides a Claude Code-style visual /context command with:
 * - Multi-colored segmented progress bar for context window usage
 * - Category breakdown with distinct ANSI colors:
 *     ■ Magenta: System Prompt & Rules (AGENTS.md, instructions)
 *     ■ Blue:    Built-in Tools Declarations
 *     ■ Cyan:    MCP Tool Declarations
 *     ■ Yellow:  User Messages
 *     ■ Green:   Assistant Messages
 *     ■ Orange:  Tool Execution Results (outputs, bash logs)
 *     ░ Dim:     Free Context Capacity
 * - Exact token counts and percentage breakdown for each category.
 */

import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { Box, Text } from "@earendil-works/pi-tui";

interface CategoryStat {
	name: string;
	tokens: number;
	color: string;
}

function estimateChars(text: unknown): number {
	if (typeof text === "string") return text.length;
	if (!text) return 0;
	try {
		return JSON.stringify(text).length;
	} catch {
		return 0;
	}
}

export default function contextBreakdownExtension(pi: ExtensionAPI) {
	// Register custom renderer to display nicely in the chat transcript
	pi.registerMessageRenderer("context-breakdown", (message, { outputPad }) => {
		const box = new Box(outputPad, 1);
		box.addChild(new Text(message.content, 0, 0));
		return box;
	});

	pi.registerCommand("context", {
		description: "Display a Claude Code-style visual context breakdown with colors and exact tokens",
		handler: async (_args: string, ctx: ExtensionCommandContext) => {
			const usage = ctx.getContextUsage();
			const model = ctx.model;
			const contextWindow = usage?.contextWindow ?? model?.contextWindow ?? 200_000;

			// 1. System Prompt & Instructions
			let systemChars = 0;
			try {
				const systemPrompt = ctx.getSystemPrompt();
				systemChars += systemPrompt ? systemPrompt.length : 0;
			} catch {
				// ignore
			}
			const systemTokens = Math.ceil(systemChars / 4);

			// 2. Tools & MCP Declarations (only count active tools declared to the model)
			let builtinToolChars = 0;
			let mcpToolChars = 0;
			try {
				const activeToolNames = new Set(pi.getActiveTools());
				const allTools = pi.getAllTools();
				for (const tool of allTools) {
					if (!activeToolNames.has(tool.name)) continue;
					const schemaChars = estimateChars({
						name: tool.name,
						description: tool.description,
						parameters: tool.parameters,
					});
					if (tool.name.startsWith("mcp__")) {
						mcpToolChars += schemaChars;
					} else {
						builtinToolChars += schemaChars;
					}
				}
			} catch {
				// ignore
			}
			const builtinToolTokens = Math.ceil(builtinToolChars / 4);
			const mcpToolTokens = Math.ceil(mcpToolChars / 4);

			// 3. Messages History
			let userChars = 0;
			let assistantChars = 0;
			let toolResultChars = 0;

			try {
				const entries = ctx.sessionManager.getEntries();
				for (const entry of entries) {
					if (entry.type === "message") {
						const msg = entry.message;
						if (msg.role === "user") {
							userChars += estimateChars(msg.content);
						} else if (msg.role === "assistant") {
							for (const block of msg.content) {
								if (block.type === "text") {
									assistantChars += block.text.length;
								} else if (block.type === "toolCall") {
									assistantChars += block.name.length + estimateChars(block.arguments);
								} else if (block.type === "thinking") {
									assistantChars += block.thinking.length;
								}
							}
						} else if (msg.role === "toolResult") {
							toolResultChars += estimateChars(msg.content);
						}
					} else if (entry.type === "compaction") {
						systemChars += entry.summary.length;
					}
				}
			} catch {
				// ignore
			}

			const userTokens = Math.ceil(userChars / 4);
			const assistantTokens = Math.ceil(assistantChars / 4);
			const toolResultTokens = Math.ceil(toolResultChars / 4);

			const calculatedUsed =
				systemTokens + builtinToolTokens + mcpToolTokens + userTokens + assistantTokens + toolResultTokens;
			const usedTokens = usage?.tokens ?? calculatedUsed;
			const freeTokens = Math.max(0, contextWindow - usedTokens);
			const usedPercent = usage?.percent ?? ((usedTokens / contextWindow) * 100);

			// Categories
			const categories: CategoryStat[] = [
				{ name: "System Prompt & Rules", tokens: systemTokens, color: "\x1b[35m" }, // Magenta
				{ name: "Built-in Tool Schemas", tokens: builtinToolTokens, color: "\x1b[34m" }, // Blue
				{ name: "MCP Tool Schemas", tokens: mcpToolTokens, color: "\x1b[36m" }, // Cyan
				{ name: "User Messages", tokens: userTokens, color: "\x1b[33m" }, // Yellow
				{ name: "Assistant Messages", tokens: assistantTokens, color: "\x1b[32m" }, // Green
				{ name: "Tool Execution Results", tokens: toolResultTokens, color: "\x1b[38;5;208m" }, // Orange
			];

			// Render visual progress bar (44 blocks)
			const barWidth = 44;
			let bar = "";
			let drawnBlocks = 0;

			for (const cat of categories) {
				if (cat.tokens <= 0) continue;
				const count = Math.max(1, Math.round((cat.tokens / contextWindow) * barWidth));
				drawnBlocks += count;
				bar += `${cat.color}${"█".repeat(count)}\x1b[0m`;
			}

			const remainingBlocks = Math.max(0, barWidth - drawnBlocks);
			bar += `\x1b[90m${"░".repeat(remainingBlocks)}\x1b[0m`;

			// Build breakdown lines
			const modelLabel = model ? `${model.provider}/${model.id}` : "unknown";
			const lines: string[] = [
				`\x1b[1mContext Window Usage\x1b[0m: ${usedTokens.toLocaleString()} / ${contextWindow.toLocaleString()} tokens (${usedPercent.toFixed(1)}%)`,
				`\x1b[90mModel: ${modelLabel}\x1b[0m\n`,
				`[${bar}]\n`,
			];

			for (const cat of categories) {
				const pct = ((cat.tokens / contextWindow) * 100).toFixed(1);
				const namePad = cat.name.padEnd(25, " ");
				const tokenPad = `${cat.tokens.toLocaleString()} tokens`.padStart(15, " ");
				lines.push(`  ${cat.color}■\x1b[0m ${namePad} ${tokenPad}  \x1b[90m(${pct}%)\x1b[0m`);
			}

			const freePct = ((freeTokens / contextWindow) * 100).toFixed(1);
			lines.push(
				`  \x1b[90m░ Free Capacity            ${freeTokens.toLocaleString().padStart(8, " ")} tokens  (${freePct}%)\x1b[0m\n`,
			);

			pi.sendMessage({
				customType: "context-breakdown",
				content: lines.join("\n"),
				display: true,
			});
		},
	});
}
