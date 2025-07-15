# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository containing configuration files for a macOS development environment. The setup includes:

- **Neovim** - Custom configuration with lua-based architecture and lazy.nvim plugin management
- **Zsh** with oh-my-zsh and antigen - Shell configuration with vi-mode and extensive development tooling
- **Tmux** - Terminal multiplexer with custom key bindings and theming
- **WezTerm** - GPU-accelerated terminal emulator with Tokyo Night theme
- **Starship** - Cross-shell prompt with vim mode indicators and development context
- **Git** - Comprehensive configuration with SSH signing via 1Password and custom aliases

## Common Commands and Workflows

### Environment Setup
```bash
# Install all dependencies and link dotfiles
./setup.sh recover

# Install packages via Homebrew
brew bundle install

# Update Neovim plugins
nvim +Lazy update

# Reload zsh configuration
source ~/.zshrc

# Update shell plugins
antigen reset && antigen apply
```

### Development Workflows
```bash
# Interactive tmux session management
m                                    # Launch tmux session picker with fzf

# Git operations with custom functions
git_clean main                       # Clean merged branches based on main
git_config_work "name" "email"       # Configure git for work environment
git_config_play "email"              # Configure git for personal projects
replace_remote work                  # Switch git remote to work configuration

# Kubernetes utilities
klogs <keyword>                      # Get logs from most recent pod matching keyword
bitnami_seal <namespace> <file>      # Seal secrets with kubeseal

# Remote development sync
rsync_work [server_number] [back]    # Sync local work to remote development servers
```

### Key Aliases
```bash
# Terminal and file management
ls -> lsd                           # Modern ls replacement
vi -> nvim                          # Neovim as default editor
pn -> pnpm                          # Package manager preference

# Git shortcuts (from git config)
git st -> git status
git co -> git checkout
git cb -> git checkout -b
git cm -> git commit -s -m
git ca -> git commit --amend -s --no-edit

# Kubernetes shortcuts
kctx -> kubectx                     # Context switching
kns -> kubens                       # Namespace switching
kget -> kubectl get
kdesc -> kubectl describe
```

## Configuration Architecture

### Shell Environment (.zshrc)
- **Package Management**: Antigen for zsh plugin management with oh-my-zsh base
- **Vi-mode**: Enabled with custom key bindings and starship prompt indicators
- **Development Paths**: Configured for Go, Rust, Node.js, Python, and Kubernetes tooling
- **Custom Functions**: Includes utilities for git operations, Kubernetes management, and remote syncing

### Neovim Configuration (nvim/)
- **Plugin Manager**: lazy.nvim with performance optimizations and lazy loading
- **Architecture**: Modular lua-based configuration with core/ and plugins/ directories
- **Language Support**: Go, Python, Rust, and general development plugins
- **Theme**: Tokyo Night colorscheme with custom UI configuration

### Terminal Setup
- **WezTerm**: Primary terminal with vim-like keybindings and Tokyo Night theme
- **Tmux**: Available with custom prefix (C-a) and vim-like navigation
- **Font**: JetBrains Mono Nerd Font with Maple Mono CN fallback

### Multi-Environment Git Support
The configuration supports multiple git identities through functions:
- `git_config_work()` - Configure work environment with work signing key
- `git_config_play()` - Configure personal environment with personal signing key
- `replace_remote()` - Switch between ops/work/play git remote configurations
- SSH signing integration with 1Password for secure commit signing

### Kubernetes Development
- Extensive kubectl aliases and custom functions for container-first development
- Context switching with kubectx/kubens
- Log monitoring with `klogs()` function
- Secret sealing with `bitnami_seal()` for GitOps workflows

## Performance Optimizations

### Neovim
- Disabled unnecessary built-in plugins (gzip, netrw, etc.)
- Lazy loading for non-essential plugins
- Treesitter for syntax highlighting and navigation

### Shell
- Antigen for efficient plugin management
- Starship for fast prompt rendering
- FZF integration for fuzzy finding
- Direnv for directory-based environment management

### Terminal
- WezTerm with GPU acceleration
- Tmux with optimized key bindings
- Custom aliases for common operations

## Development Tools Integration

### 1Password Integration
- SSH agent configured for commit signing
- Git signing key management through 1Password SSH agent

### Package Managers
- Homebrew for macOS packages and applications
- pnpm preferred over npm for Node.js projects
- Rust via rustup with clippy component

### Language Tooling
- Go development with proper GOPATH configuration
- Python with pip3 and virtual environment support
- Rust with cargo and rustup integration
- Node.js with pnpm and proper PATH configuration