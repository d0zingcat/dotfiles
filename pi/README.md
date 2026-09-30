# Pi credential boundary for ~/.pi/agent

pi's agent directory mixes shareable config with real credentials, and pi rewrites part of
it at runtime. This directory tracks only the config half.

## Committed (symlinked into ~/.pi/agent)

| Path | Why it is safe |
|---|---|
| `agent/settings.json` | model defaults, theme, package list |
| `agent/models.json` | custom provider + model overrides; keys are `${VAR}` or absent |
| `agent/pi-plan-mode.json` | plan-mode thinking level |
| `agent/mcp.json` | `${VAR}` template only — no literal credentials |
| `agent/extensions/` | our own `effort.ts`, `balance-status.ts`, `context-breakdown.ts` + pi's subagent extension |
| `agent/agents/`, `agent/prompts/` | subagent role/prompt markdown |

Symlinks mean an edit in `~/.pi/agent` is an edit in the repo working tree: review with
`git diff pi` and commit. pi rewrites `settings.json` on `/settings`, `/model` Ctrl+S and
`pi install`, so expect incidental churn there (e.g. `lastChangelogVersion`).

## Never committed

| Path | Reason |
|---|---|
| `agent/auth.json` | provider API keys + OAuth refresh tokens |
| `agent/mcp-auth.json` | MCP OAuth tokens |
| `agent/antigravity-accounts.json` | Antigravity account OAuth tokens |
| `agent/secrets.env` | env values consumed by `mcp.json` |
| `agent/sessions/` | ~20MB conversation transcripts (privacy, not just size) |
| `agent/models-store.json*` | pi's model catalog cache, regenerates via `pi update --models` |
| `agent/trust.json` | per-machine project-trust decisions |
| `agent/npm/` | installed package tree (~14MB, regenerates) |
| `*.pre-copy` | install-time backups of unlinked files |

The names above are blocked in the repo-root `.gitignore` and refused by the scanner even
if someone force-adds them.

## MCP credentials

`agent/mcp.json` holds only references:

```json
"env": {
  "DOKPLOY_URL": "${DOKPLOY_URL}",
  "DOKPLOY_API_KEY": "${DOKPLOY_API_KEY}",
  "DOKPLOY_CUSTOM_HEADERS": "${DOKPLOY_CF_ACCESS_HEADERS}"
}
```

pi resolves `${NAME}` from its own process environment, so the values must be in the shell
that starts pi. That is `~/.pi/agent/secrets.env` (mode 600), sourced from `~/.zshrc`:

```zsh
# ==== Pi agent config (dotfiles-managed; see ~/.dotfiles/pi/README.md)
if [[ -f "$HOME/.pi/agent/secrets.env" ]]; then
    source "$HOME/.pi/agent/secrets.env"
fi
```

`agent/secrets.env.example` documents the variable names; copy it and fill in real values.
A missing variable leaves the literal `${NAME}` in the server config, so that server fails
to authorize while the others keep working.

## Restore on a new machine

```bash
./setup.sh install                  # links everything above into ~/.pi/agent
cp ~/.dotfiles/pi/agent/secrets.env.example ~/.pi/agent/secrets.env
chmod 600 ~/.pi/agent/secrets.env
$EDITOR ~/.pi/agent/secrets.env     # real values, never committed

pi install npm:@narumitw/pi-plan-mode   # recreates agent/npm/ + settings.json entry
pi install npm:pi-antigravity
pi auth ...                             # or /login in a pi session -> agent/auth.json
pi update --models                      # recreates agent/models-store.json

source ~/.zshrc
pi mcp list                         # expect: every server "connected"
bash ~/.dotfiles/scripts/pi-secrets-scan.sh
```

## Guard

```bash
scripts/pi-secrets-scan.sh              # scan every file under pi/ (tracked or not)
scripts/pi-secrets-scan.sh <path>...    # scan specific files/dirs (pre-copy gate)
scripts/pi-secrets-scan.sh --all        # scan every tracked file in the repo
```

Exit 0 clean, 1 findings. It rejects reserved credential filenames and credential-shaped
content (`sk-…`, `ya29.…`, `1//…`, `cfast_…`, literal `"apiKey": "…"`, private-key blocks).
`${VAR}` references and `REPLACE_ME` placeholders pass. Mark a reviewed false positive with
an `allowsecret` comment on the same line.
