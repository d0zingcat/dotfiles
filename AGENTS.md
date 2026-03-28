# Repository Guidelines

## Project Structure & Module Organization
This repository manages macOS dotfiles and bootstrap scripts. Root-level files such as [setup.sh](/Users/d0zingcat/.dotfiles/setup.sh), [Brewfile](/Users/d0zingcat/.dotfiles/Brewfile), [README.md](/Users/d0zingcat/.dotfiles/README.md), and [QUICKSTART.md](/Users/d0zingcat/.dotfiles/QUICKSTART.md) drive installation and recovery. App-specific config lives in `nvim/`, `wezterm/`, `alacritty/`, `ghostty/`, `git/`, `direnv/`, `ssh/`, and `tmux/`. Neovim code is organized under `nvim/lua/config` for core behavior and `nvim/lua/plugins` for plugin specs. `tmux/plugins/tpm` is a Git submodule; treat it as vendored code unless you are intentionally updating TPM.

## Build, Test, and Development Commands
Use the setup script instead of ad hoc symlink changes:

- `./setup.sh install`: link managed files into `$HOME` and `$HOME/.config`.
- `./setup.sh check`: verify expected tools, links, and directories.
- `./setup.sh full-recover`: bootstrap a new machine end to end.
- `./setup.sh backup`: refresh tracked backup artifacts such as `Brewfile`.
- `brew bundle install`: install CLI tools and apps from [Brewfile](/Users/d0zingcat/.dotfiles/Brewfile).
- `tmux/plugins/tpm/tests/test_plugin_installation.sh`: example TPM plugin test entrypoint when working inside the submodule.

## Coding Style & Naming Conventions
Shell code is written for `zsh`; keep functions small, prefer descriptive names like `cmd_install`, and follow the existing 4-space indentation in [setup.sh](/Users/d0zingcat/.dotfiles/setup.sh). Lua plugin files in `nvim/lua/plugins` use lowercase filenames grouped by concern, for example `python.lua` and `lspconfig.lua`. Keep new config directories lowercase and mirror their target app name. For Python-style checks, [pycodestyle](/Users/d0zingcat/.dotfiles/pycodestyle) ignores `E501`. Neovim tooling references `stylua`, `luacheck`, and `shellcheck`; use them when available before submitting changes.

## Testing Guidelines
There is no top-level test suite for the dotfiles themselves, so validate changes with `./setup.sh check` and, when relevant, a dry run on a disposable shell session. Automated tests currently live under `tmux/plugins/tpm/tests`; keep test scripts executable and named `test_*.sh`.

## Commit & Pull Request Guidelines
Recent history favors short imperative subjects, often Conventional Commit style: `feat: add deps`, `refactor(nvim): simplify fold config`, `docs: 更新备份相关文档说明`. Prefer `type: summary` for new work and keep subjects under roughly 72 characters. PRs should describe user-visible config changes, list any manual setup steps, link related issues, and include screenshots only for terminal or editor UI changes.

## Security & Configuration Tips
Do not commit secrets from `~/.ssh`, `~/.kube`, `.1password`, or local backup outputs. Treat `git/config` and `ssh/example` as templates only: `./setup.sh install` should copy them into place for local editing rather than symlinking machine-specific values back into the repository.
