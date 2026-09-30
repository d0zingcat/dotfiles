/**
 * /effort — Claude-Code-style control for Pi's thinking level.
 *
 *   /effort              pick a level (picker lists what the current model supports)
 *   /effort <level>      set the level for this session
 *   /effort show         print the current level plus the configured mode defaults
 *
 * Levels: off | minimal | low | medium | high | xhigh | max
 * Pi clamps the request to what the active model supports.
 *
 * This command only changes the running session. Per-mode defaults live in config:
 *   - agent/normal mode: <agent-dir>/settings.json        -> defaultThinkingLevel
 *   - plan mode:         <agent-dir>/pi-plan-mode.json    -> thinkingLevel
 */

import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const LEVELS = ["off", "minimal", "low", "medium", "high", "xhigh", "max"] as const;
type Level = (typeof LEVELS)[number];

type ThinkableModel = {
	reasoning?: boolean;
	thinkingLevelMap?: Partial<Record<Level, unknown>> | null;
};

/** Mirrors pi-ai's getSupportedThinkingLevels(). */
function supportedLevels(model: ThinkableModel | undefined): Level[] {
	if (!model?.reasoning) return ["off"];
	return LEVELS.filter((level) => {
		const mapped = model.thinkingLevelMap?.[level];
		if (mapped === null) return false;
		if (level === "xhigh" || level === "max") return mapped !== undefined;
		return true;
	});
}

function agentDir(): string {
	return process.env.PI_CODING_AGENT_DIR || join(homedir(), ".pi", "agent");
}

function readJson(path: string): Record<string, unknown> | undefined {
	try {
		if (!existsSync(path)) return undefined;
		const parsed: unknown = JSON.parse(readFileSync(path, "utf8"));
		return parsed && typeof parsed === "object" ? (parsed as Record<string, unknown>) : undefined;
	} catch {
		return undefined;
	}
}

function defaultLevels(): { agent?: string; plan?: string } {
	const settings = readJson(join(agentDir(), "settings.json"));
	const planMode = readJson(join(agentDir(), "pi-plan-mode.json"));
	return {
		agent: typeof settings?.defaultThinkingLevel === "string" ? settings.defaultThinkingLevel : undefined,
		plan: typeof planMode?.thinkingLevel === "string" ? planMode.thinkingLevel : undefined,
	};
}

export default function effortExtension(pi: ExtensionAPI) {
	pi.registerCommand("effort", {
		description: "Show or set thinking effort (/effort [off|minimal|low|medium|high|xhigh|max|show])",
		getArgumentCompletions: (prefix) => {
			const needle = (prefix ?? "").toLowerCase();
			const hits = [...LEVELS, "show"].filter((level) => level.startsWith(needle));
			return hits.length > 0 ? hits.map((level) => ({ value: level, label: level })) : null;
		},
		handler: async (args, ctx) => {
			const requested = args.trim().toLowerCase();
			const current = pi.getThinkingLevel();
			const modelName = ctx.model?.name || ctx.model?.id || "no model";

			const apply = (level: Level) => {
				pi.setThinkingLevel(level);
				const effective = pi.getThinkingLevel();
				ctx.ui.notify(
					effective === level
						? `Thinking effort: ${effective} (${modelName})`
						: `Thinking effort: ${effective} — ${level} was clamped by ${modelName}`,
					"info",
				);
			};

			if (requested === "show" || requested === "status") {
				const { agent, plan } = defaultLevels();
				const defaults = [agent ? `agent default ${agent}` : undefined, plan ? `plan default ${plan}` : undefined]
					.filter((part): part is string => Boolean(part))
					.join(", ");
				ctx.ui.notify(`Thinking effort: ${current} (${modelName})${defaults ? ` — ${defaults}` : ""}`, "info");
				return;
			}

			if (!requested) {
				if (!ctx.hasUI) {
					ctx.ui.notify(`Thinking effort: ${current}. Use /effort <level>.`, "info");
					return;
				}
				const levels = ctx.model ? supportedLevels(ctx.model as ThinkableModel) : [...LEVELS];
				if (levels.length <= 1) {
					ctx.ui.notify(`${modelName} has no thinking support (level: ${current}).`, "warning");
					return;
				}
				const picked = await ctx.ui.select(
					`Thinking effort (current: ${current})`,
					levels.map((level) => (level === current ? `${level} — current` : level)),
				);
				if (!picked) return;
				const level = picked.split(" — ")[0] as Level;
				apply(level);
				return;
			}

			if (!(LEVELS as readonly string[]).includes(requested)) {
				ctx.ui.notify(`Unknown effort "${requested}". Use: ${LEVELS.join(" | ")} (or /effort to pick).`, "error");
				return;
			}
			apply(requested as Level);
		},
	});
}
