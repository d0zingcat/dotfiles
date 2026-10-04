# User-level Pi instructions

Project `AGENTS.md` files take precedence for project-specific work.

## Develop in a git worktree

Any change to tracked files goes in a worktree of that repo, checked out under the project's own
`.worktree/` directory (keep it git-ignored), never in the main checkout. Merge it back once it
lands, then remove the worktree and its branch.

## Never edit Pi's own rules or config in place

`~/.pi/agent/*` symlinks into `~/.dotfiles/pi/agent/`, so an in-place edit mutates the live context
of every running pi session together with the repo's `main` checkout. Iterate rule and config files
(`AGENTS.md`, `SYSTEM.md`, `settings.json`, `models.json`, `mcp.json`, `agents/`, `prompts/`,
`extensions/`) in a worktree of `~/.dotfiles` and merge to `main` to activate.
Commands and caveats: `~/.dotfiles/pi/README.md`.
