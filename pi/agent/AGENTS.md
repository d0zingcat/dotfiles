# User-level Pi instructions

These rules apply in every working directory. Project `AGENTS.md` files still win for
project-specific work.

## Never edit Pi's rule or config files in place — iterate in a git worktree

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
