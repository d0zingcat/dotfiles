/**
 * Pi statusline: live balance for the currently-used model provider.
 *
 * Mirrors ~/.claude/statusline.js but only shows the balance of the provider
 * backing the active model. Reads credentials through
 * ctx.modelRegistry.getProviderAuth() so it uses whatever is configured in
 * auth.json / models.json, then fetches:
 *   - Vercel AI Gateway -> GET {base}/v1/credits   -> data.balance (USD)
 *   - DeepSeek          -> GET {base}/user/balance -> balance_infos[0] (CNY)
 *
 * Refreshes on session start, on model change, and then every REFRESH_MS.
 * Any failure renders "bal --" rather than breaking the statusline.
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const REFRESH_MS = 30 * 60 * 1000; // 30 minutes

// Provider id -> balance endpoint kind. Only these are supported; anything
// else renders "bal --".
const SUPPORTED: Record<string, "vercel" | "deepseek"> = {
  "vercel-ai-gateway": "vercel",
  deepseek: "deepseek",
};

// Known gateway/API hosts, used as a fallback when the provider auth result
// does not carry a baseUrl (these providers set baseUrl per-model).
const DEFAULT_BASE: Record<string, string> = {
  "vercel-ai-gateway": "https://ai-gateway.vercel.sh",
  deepseek: "https://api.deepseek.com",
};

const STATUS_ID = "provider-balance";

export default function (pi: ExtensionAPI) {
  async function refresh(ctx: ExtensionContext) {
    const theme = ctx.ui.theme;
    const provider = ctx.model?.provider;
    const kind = provider ? SUPPORTED[provider] : undefined;
    try {
      if (!provider || !kind) {
        ctx.ui.setStatus(STATUS_ID, theme.fg("dim", "bal --"));
        return;
      }
      const bal = await fetchBalance(ctx, provider, kind);
      const label = kind === "vercel" ? "vercel" : "deepseek";
      ctx.ui.setStatus(
        STATUS_ID,
        theme.fg("dim", `${label} `) + theme.fg("accent", bal ?? "--"),
      );
    } catch {
      ctx.ui.setStatus(STATUS_ID, theme.fg("dim", "bal --"));
    }
  }

  pi.on("session_start", async (_event, ctx) => {
    await refresh(ctx);
    const timer = setInterval(() => refresh(ctx), REFRESH_MS);
    // Best-effort cleanup so the timer never outlives the session.
    pi.on("session_shutdown", () => clearInterval(timer));
  });

  pi.on("model_select", async (_event, ctx) => {
    await refresh(ctx);
  });
}

/** Resolve a provider's API key + base URL, falling back to known defaults. */
async function resolveProvider(
  ctx: ExtensionContext,
  providerId: string,
): Promise<{ base: string; key: string } | undefined> {
  const auth = await ctx.modelRegistry.getProviderAuth(providerId);
  const key = auth?.auth?.apiKey?.trim();
  const base = auth?.auth?.baseUrl?.trim() || DEFAULT_BASE[providerId];
  if (!key || !base) return undefined;
  return { base: base.replace(/\/+$/, ""), key };
}

async function fetchJson(
  url: string,
  key: string,
): Promise<Record<string, unknown>> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), 5000);
  try {
    const res = await fetch(url, {
      headers: { Authorization: `Bearer ${key}`, Accept: "application/json" },
      signal: controller.signal,
    });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    return (await res.json()) as Record<string, unknown>;
  } finally {
    clearTimeout(timer);
  }
}

async function fetchBalance(
  ctx: ExtensionContext,
  providerId: string,
  kind: "vercel" | "deepseek",
): Promise<string | undefined> {
  const p = await resolveProvider(ctx, providerId);
  if (!p) return undefined;
  if (kind === "vercel") {
    const data = await fetchJson(`${p.base}/v1/credits`, p.key);
    const balance = Number(data.balance);
    if (!Number.isFinite(balance)) return undefined;
    return `$${balance.toFixed(2)}`;
  }
  const data = await fetchJson(`${p.base}/user/balance`, p.key);
  const info = (data.balance_infos as Array<{ currency?: string; total_balance?: unknown }> | undefined)?.[0];
  const total = Number(info?.total_balance);
  if (!Number.isFinite(total)) return undefined;
  const symbol = info?.currency === "CNY" ? "¥" : (info?.currency || "");
  return `${symbol}${total.toFixed(2)}`;
}
