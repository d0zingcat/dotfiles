# User-level Pi instructions

These rules apply in every working directory. Project `AGENTS.md` files still win for
project-specific work.

## Development happens in a git worktree under `<repo>/.worktree/`

When a task changes tracked files in a git repository, create a worktree inside that repo and do
the work there instead of in the checkout you were handed. Read-only work (explaining code,
reviewing, querying data) needs no worktree; neither does a directory that is not a git repo.

```bash
cd <repo>
git worktree add .worktree/<topic> -b <type>/<topic>
cd .worktree/<topic>            # bootstrap here: uv sync / pnpm install / submodule init
# develop, test and commit on the branch
cd <repo>
git merge --ff-only <type>/<topic>   # or push + PR, whatever the project requires
git worktree remove .worktree/<topic> && git branch -d <type>/<topic>
git worktree list                    # should end with only the main checkout
```

Why: the main checkout stays clean and shippable while you iterate, a half-finished change can
never be picked up by a build, deploy, or another parallel session reading from it, and each idea
gets its own discardable directory instead of a stash dance.

Rules of the road:

- `.worktree/` goes *inside* the repo, never beside it, so pi still finds the project's
  `AGENTS.md`, `.env`, direnvrc, lockfiles and tool paths by walking upwards.
- Make sure git ignores it before starting: `.worktree/` in `.gitignore`, or — when you must not
  touch tracked shared files — in `.git/info/exclude`. Confirm with `git status --porcelain`.
- A worktree is a fresh checkout, not a copy: dependencies are yours to install, and anything
  read from outside git (`.env`, database URLs, DuckDB/Parquet under `data/`, model artifacts)
  must be located explicitly. Prefer a uniquely named scratch database over sharing one, and never
  point a worktree's migrations at a shared or production database.
- The session's cwd does not move by itself: run commands from inside the worktree (or `git -C`),
  and state which path you worked in.
- One task, one worktree, one branch: with parallel agents, keep topic names 1:1 across branch,
  directory and database names so runs cannot collide.
- Project rules win: worktree + that project's branch/PR flow, never committing or merging
  straight onto a protected default branch. If a project prescribes something different, follow
  the project and say so.
- Land it, then clean up. Stale worktrees make `git worktree list`, `git branch -a` and disk
  usage misreport the state of the repo.

## Never edit Pi's rule or config files in place — iterate in a git worktree

This is the strict case of the rule above: `~/.dotfiles` is an ordinary repo, but its rule files
are live context, so an in-place edit there is never merely a local edit.

`~/.pi/agent/*` is a set of symlinks into the `~/.dotfiles` repo (`pi/agent/...`). Writing
to a live path therefore writes straight into the repo's `main` checkout and takes effect
in every running pi session, with no review step and no way back except another edit.

So when asked to add, change, or "tune" pi's own instructions or config, do not edit any of
these in place:

- `~/.dotfiles/pi/agent/AGENTS.md` (this file), `SYSTEM.md`, `APPEND_SYSTEM.md`
- `~/.dotfiles/pi/agent/settings.json`, `models.json`, `pi-plan-mode.json`, `mcp.json`
- `~/.dotfiles/pi/agent/{agents,prompts,extensions,skills,themes}/`
- `~/.dotfiles/AGENTS.md` (the dotfiles repo guidance)

Run the iteration inside a worktree of `~/.dotfiles` instead:

```bash
git -C ~/.dotfiles worktree add .worktree/<topic> -b chore/pi-rules-<topic>
cd ~/.dotfiles/.worktree/<topic>
# edit pi/agent/... here, never in ~/.dotfiles or ~/.pi/agent
bash scripts/pi-secrets-scan.sh pi/agent/          # gate the change
git add -A && git commit -m "chore(pi): <summary>"
cd ~/.dotfiles && git merge --ff-only chore/pi-rules-<topic>
ln -svfn ~/.dotfiles/pi/agent/<file> ~/.pi/agent/<file>   # link new entries; skip if it already links
./setup.sh check                                   # read-only: verifies every PI_LINKS entry
git worktree remove .worktree/<topic> && git branch -d chore/pi-rules-<topic>
```

Notes that matter:

- **Merging into `main` is the activation step.** The symlinks point at the `main` checkout,
  so a rule only goes live when the branch is merged. Draft freely in the worktree.
- Do **not** run `./setup.sh install` for a rule-only change: it relinks every managed dotfile
  and re-copies `git/config` over `~/.gitconfig`. It is also unsafe from inside a worktree —
  `$WORKING_DIR` is the script's own directory, so it would repoint `$HOME` at the worktree.
  Link the single changed entry with `ln -svfn` and verify with `./setup.sh check`.
- `.worktree/` is gitignored and lives *inside* the repo on purpose: pi discovers context
  files from the working directory upwards, so repo-root guidance still applies there.
- After a merge, say that running sessions need `/reload` (or a pi restart) to pick the new
  text up; you cannot reload another session's context yourself.
- If the request is ambiguous — what a rule should say, which file owns it, whether it
  should be user-level or project-level — ask before writing. Rule files are global blast
  radius; guessing is not acceptable there.
- If a change should apply to one project only, put it in that project's own `AGENTS.md`
  and iterate it with that project's git workflow (feature branch + PR), not here.
- Never commit pi credentials or runtime state (`auth.json`, `mcp-auth.json`,
  `antigravity-accounts.json`, `secrets.env`, `sessions/`, `models-store.json`,
  `trust.json`, `npm/`) — see `~/.dotfiles/pi/README.md`.
