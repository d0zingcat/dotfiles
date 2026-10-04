# Pi credential boundary for ~/.pi/agent

pi's agent directory mixes shareable config with real credentials, and pi rewrites part of
it at runtime. This directory tracks only the config half.

## Committed (symlinked into ~/.pi/agent)

| Path | Why it is safe |
|---|---|
| `agent/AGENTS.md` | user-level pi rules (context file loaded in every project) — prose only, no credentials |
| `agent/settings.json` | model defaults, theme, package list |
| `agent/models.json` | custom provider + model overrides; keys are `${VAR}` or absent |
| `agent/pi-plan-mode.json` | plan-mode thinking level |
| `agent/mcp.json` | `${VAR}` template only — no literal credentials |
| `agent/extensions/` | our own `effort.ts`, `balance-status.ts`, `context-breakdown.ts` + pi's subagent extension |
| `agent/agents/`, `agent/prompts/` | subagent role/prompt markdown |

Symlinks mean an edit in `~/.pi/agent` is an edit in the repo working tree: review with
`git diff pi` and commit. pi rewrites `settings.json` on `/settings`, `/model` Ctrl+S and
`pi install`, so expect incidental churn there (e.g. `lastChangelogVersion`).

## Iterating on rule files: use a worktree

`agent/AGENTS.md` and the repo-root `AGENTS.md` are live context: because of the symlinks,
an edit in the `main` checkout changes what every running pi session is told to do,
immediately and unreviewed. So rule text is never edited in place. Draft it in a worktree
and let the merge be the activation step:

```bash
git -C ~/.dotfiles worktree add .worktree/pi-rules -b chore/pi-rules-<topic>
cd ~/.dotfiles/.worktree/pi-rules
# edit pi/agent/AGENTS.md (or agents/, prompts/, extensions/) here
git add -A && git commit -m "chore(pi): <summary>"
cd ~/.dotfiles && git merge --ff-only chore/pi-rules-<topic>
# a new entry also needs its link (idempotent, one file only):
ln -svfn ~/.dotfiles/pi/agent/AGENTS.md ~/.pi/agent/AGENTS.md
./setup.sh check                                   # read-only: verifies every PI_LINKS entry
git worktree remove .worktree/pi-rules && git branch -d chore/pi-rules-<topic>
```

`.worktree/` is gitignored and sits inside the repo on purpose, so pi still discovers the
repo-root `AGENTS.md` by walking up from the worktree. Already-running sessions keep the old
text until `/reload` or a restart. `./setup.sh check` verifies every `PI_LINKS` entry, so a
missing rule file shows up as a failure instead of silently running without it.

Do not reach for `./setup.sh install` to activate a rule change: it relinks every managed
dotfile and re-copies `git/config` over `~/.gitconfig`, and running it from inside a worktree
would repoint `$HOME` at the worktree because `$WORKING_DIR` is the script's own directory.

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
pi mcp list                                   # expect: every server "connected"
bash ~/.dotfiles/scripts/pi-secrets-scan.sh
bash ~/.dotfiles/scripts/pi-credential-audit.sh   # nothing leaked, nothing dropped
```

## Guard

**Shape check** (fast; run before committing):

```bash
scripts/pi-secrets-scan.sh              # scan every file physically under pi/
scripts/pi-secrets-scan.sh <path>...    # scan specific files/dirs (pre-copy gate)
scripts/pi-secrets-scan.sh --all        # scan every tracked file in the repo
```

Exit 0 clean, 1 findings. It rejects reserved credential filenames and credential-shaped
content (`sk-…`, `ya29.…`, `1//…`, `cfast_…`, literal `"apiKey": "…"`, private-key blocks).
`${VAR}` references and `REPLACE_ME` placeholders pass. Mark a reviewed false positive with
an `allowsecret` comment on the same line.

**Exact-value audit** (~20s; walks all of history) answers the sharper question: "did any of
the keys I actually use leak into this repo, and did anything get dropped while
migrating?"

```bash
scripts/pi-credential-audit.sh
```

It harvests every credential value pi uses on this machine — `auth.json` keys and OAuth
tokens, `mcp-auth.json`, `antigravity-accounts.json`, and `secrets.env` including values
nested inside JSON header blobs — then searches each literal value in the working tree, the
git index, and every commit in history. Values are never printed (labels and redacted
excerpts only), and the temporary value list is a mode-600 `mktemp` file removed on exit.
It then checks restore readiness: credential files are still real files rather than repo
links and are mode 600, every `${VAR}` in `mcp.json` has a non-empty definition, and
`pi auth check` passes for the configured startup provider/model. Exit 0 = nothing leaked,
nothing lost.
