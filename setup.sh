#!/usr/bin/env zsh
#
# dotfiles Setup Script
# Usage: ./setup.sh [command]
#
# Commands:
#   init           - Initialize a brand new macOS system
#   install        - Install dotfiles symlinks
#   backup         - Backup current configuration
#   sync           - Sync from git repository
#   full-recover   - Full recovery on new machine (init + install + sync)
#   check          - Check current setup status
#   help           - Show this help message

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
WORKING_DIR=$(cd "$(dirname "$0")" && pwd)
HOME_DIR="$HOME"

# Files to link
FILES=(
    .zshrc
    .tmux.conf
)

# Config directories to link
CONFIG_FILES=(
    alacritty
    git
    nvim
    tmux
    pycodestyle
    wezterm
    starship.toml
    stylua.toml
    direnv
    ghostty
)

# Rustup components
RUSTUP_COMPONENTS=(
    clippy
    rustfmt
)

# Kubectl krew plugins (commented out by default - enable as needed)
KUBECTL_COMPONENTS=(
    # ctx
    # ns
    # tail
    # tree
    # view-secret
    # who-can
    # cost
    # neat
    # sniff
    # access-matrix
    # pod-dive
    # pod-chaos
    # pod-shell
    # pod-logs
)

# =============================================================================
# Utility Functions
# =============================================================================

function print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

function print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

function print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

function print_error() {
    echo -e "${RED}✗ $1${NC}"
}

function command_exists() {
    command -v "$1" >/dev/null 2>&1
}

function ask() {
    local prompt="$1"
    local default="${2:-n}"
    local choices="y/N"
    [[ "$default" == "y" ]] && choices="Y/n"

    read -q "?$prompt [$choices] " response
    echo
    response=${response:-$default}
    [[ "$response" =~ ^[Yy] ]]
}

# =============================================================================
# Commands
# =============================================================================

function cmd_help() {
    cat << EOF
dotfiles Setup Script

Usage: ./setup.sh [command]

Commands:
    init           Initialize a brand new macOS system (Homebrew, Xcode, etc.)
    install        Install dotfiles symlinks to home directory
    backup         Backup current configuration to dotfiles repo
    sync           Sync from git repository
    full-recover   Full recovery on new machine (init + install + sync)
    check          Check current setup status
    help           Show this help message

Examples:
    ./setup.sh init              # Initialize new system
    ./setup.sh install           # Link dotfiles
    ./setup.sh full-recover      # Full setup on new machine
    ./setup.sh check             # Check what's installed

For more information, see README.md
EOF
}

function cmd_init() {
    print_header "Initializing macOS System"

    # Check for Homebrew
    if command_exists brew; then
        print_success "Homebrew already installed"
    else
        print_warning "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
        print_success "Homebrew installed"
    fi

    # Xcode Command Line Tools
    print_warning "Installing Xcode Command Line Tools..."
    xcode-select --install
    sudo xcodebuild -license accept 2>/dev/null || true
    print_success "Xcode tools ready"

    # Install antigen for zsh
    if [ ! -f "$HOME/.antigen/antigen.zsh" ]; then
        print_warning "Installing zsh antigen..."
        mkdir -p "$HOME/.antigen/"
        curl -L git.io/antigen > "$HOME/.antigen/antigen.zsh"
        print_success "Antigen installed"
    else
        print_success "Antigen already installed"
    fi

    # Create necessary directories
    print_warning "Creating directories..."
    mkdir -p "$HOME/.config/"
    mkdir -p "$HOME/.ssh"
    mkdir -p "$HOME/.kube"
    print_success "Directories created"

    # Set default macOS preferences
    print_warning "Setting macOS preferences..."
    defaults write -g ApplePressAndHoldEnabled -bool false 2>/dev/null || true
    defaults write -g KeyRepeat -int 2 2>/dev/null || true
    defaults write -g InitialKeyRepeat -int 15 2>/dev/null || true
    print_success "Preferences set"

    print_header "Init Complete!"
    echo "Now run: ./setup.sh install"
}

function cmd_install() {
    print_header "Installing Dotfiles Symlinks"

    mkdir -p "$HOME_DIR/.config"
    mkdir -p "$HOME_DIR/.ssh"
    mkdir -p "$HOME_DIR/.kube"
    mkdir -p "$HOME_DIR/.1password"

    local op_agent_target="$HOME_DIR/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    local op_agent_link="$HOME_DIR/.1password/agent.sock"
    if [ -S "$op_agent_target" ]; then
        if [ -L "$op_agent_link" ]; then
            local op_link_target
            op_link_target=$(readlink "$op_agent_link")
            if [ "$op_link_target" = "$op_agent_target" ]; then
                print_success "1Password SSH agent link already exists"
            else
                print_warning "~/.1password/agent.sock points elsewhere; leaving it unchanged"
            fi
        elif [ -e "$op_agent_link" ]; then
            print_warning "~/.1password/agent.sock already exists; leaving it unchanged"
        else
            ln -s "$op_agent_target" "$op_agent_link"
            print_success "Linked 1Password SSH agent"
        fi
    else
        print_warning "1Password SSH agent socket not found yet"
    fi

    # Link files
    print_warning "Linking files..."
    for i in "${FILES[@]}"; do
        if [ -f "$WORKING_DIR/$i" ]; then
            ln -svfn "$WORKING_DIR/$i" "$HOME_DIR/$i"
            print_success "Linked: $i"
        else
            print_warning "Not found: $i"
        fi
    done

    # Link config directories
    print_warning "Linking config directories..."
    for i in "${CONFIG_FILES[@]}"; do
        if [ -e "$WORKING_DIR/$i" ]; then
            ln -svfn "$WORKING_DIR/$i" "$HOME_DIR/.config/$i"
            print_success "Linked: .config/$i"
        else
            print_warning "Not found: $i"
        fi
    done

    # Install git config from template by copying it into place.
    local git_config_template="$WORKING_DIR/git/config"
    local git_config_target="$HOME_DIR/.gitconfig"
    if [ -f "$git_config_template" ]; then
        if [ -L "$git_config_target" ]; then
            rm "$git_config_target"
        fi
        cp -f "$git_config_template" "$git_config_target"
        print_success "Copied git config template to ~/.gitconfig"
    else
        print_warning "Not found: git/config"
    fi

    # Install SSH config from template without symlinking it into the repo.
    local ssh_template="$WORKING_DIR/ssh/example"
    local ssh_target="$HOME_DIR/.ssh/config"
    if [ -f "$ssh_template" ]; then
        if [ -L "$ssh_target" ]; then
            local ssh_link_target
            ssh_link_target=$(readlink "$ssh_target")
            if [ "$ssh_link_target" = "$WORKING_DIR/ssh/config" ] || [ "$ssh_link_target" = "$ssh_template" ]; then
                rm "$ssh_target"
                cp "$ssh_template" "$ssh_target"
                print_success "Copied SSH config from template"
            else
                print_warning "~/.ssh/config is a custom symlink; leaving it unchanged"
            fi
        elif [ -f "$ssh_target" ]; then
            print_warning "~/.ssh/config already exists; leaving it unchanged"
        else
            cp "$ssh_template" "$ssh_target"
            print_success "Copied SSH config from template"
        fi
    fi

    # Initialize git config excludesfile
    print_warning "Configuring git..."
    git config --global core.excludesfile ~/.config/git/.gitignore 2>/dev/null || true
    git config --global init.defaultBranch main 2>/dev/null || true
    print_success "Git configured"

    # Install fzf
    if command_exists fzf; then
        print_success "fzf already installed"
    elif command_exists brew; then
        if [ -x "$(brew --prefix)/opt/fzf/install" ]; then
            print_warning "Installing fzf shell integration..."
            "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc 2>/dev/null || true
            print_success "fzf shell integration installed"
        else
            print_warning "fzf binary not found yet; run: brew bundle install"
        fi
    fi

    print_header "Installation Complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Configure git: git config --file ~/.gitconfig user.name 'Your Name'"
    echo "  2. Restart terminal or run: source ~/.zshrc"
    echo "  3. Run: brew bundle install (to install packages)"
}

function cmd_backup() {
    print_header "Backing Up Configuration"

    local backup_count=0
    local backup_warnings=0

    # ==========================================================================
    # 1. Brewfile 备份
    # ==========================================================================
    print_warning "Dumping Brewfile..."
    if command_exists brew; then
        brew bundle dump -f --file="$WORKING_DIR/Brewfile"
        print_success "Brewfile saved"
        backup_count=$((backup_count + 1))
    else
        print_error "Homebrew not found"
        backup_warnings=$((backup_warnings + 1))
    fi

    # ==========================================================================
    # 2. Git 配置检查与备份（脱敏）
    # ==========================================================================
    print_warning "Checking git config..."
    if [ -f "$WORKING_DIR/git/config" ]; then
        if grep -qE "YOUR_NAME|YOUR_EMAIL|YOUR_SSH_SIGNING_KEY" "$WORKING_DIR/git/config" 2>/dev/null; then
            print_success "git/config uses placeholders (safe to commit)"
        else
            print_warning "git/config contains real values - backing up as .gitconfig.backup (NOT committed)"
            cp "$WORKING_DIR/git/config" "$WORKING_DIR/git/config.backup.$(date +%Y%m%d)"
            backup_count=$((backup_count + 1))
        fi
    fi

    print_warning "Exporting git config summary..."
    local git_name=$(git config --global user.name 2>/dev/null || echo "not set")
    local git_email=$(git config --global user.email 2>/dev/null || echo "not set")
    local git_key=$(git config --global user.signingkey 2>/dev/null || echo "not set")

    cat > "$WORKING_DIR/.git_config_summary.txt" << EOF
# Git Configuration Summary
# Generated: $(date '+%Y-%m-%d %H:%M:%S')
# WARNING: This file contains sensitive information - DO NOT COMMIT

user.name = $git_name
user.email = $git_email
user.signingkey = $git_key

# To restore on new machine:
# git config --global user.name "$git_name"
# git config --global user.email "$git_email"
# git config --global user.signingkey "$git_key"
EOF
    print_success "Git config summary exported to .git_config_summary.txt"
    backup_count=$((backup_count + 1))

    # ==========================================================================
    # 3. SSH 公钥备份
    # ==========================================================================
    print_warning "Backing up SSH public keys..."
    local ssh_backup_dir="$WORKING_DIR/ssh_backup_$(date +%Y%m%d_%H%M%S)"

    if [ -d "$HOME/.ssh" ]; then
        mkdir -p "$ssh_backup_dir"

        for key in "$HOME"/.ssh/*.pub; do
            if [ -f "$key" ]; then
                cp "$key" "$ssh_backup_dir/"
                print_success "Copied: $(basename "$key")"
            fi
        done

        if [ -f "$HOME/.ssh/config" ]; then
            cp "$HOME/.ssh/config" "$ssh_backup_dir/"
            print_success "Copied: ssh config"
        fi

        if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
            echo "# SSH Public Key Backup" > "$ssh_backup_dir/README.md"
            echo "# Generated: $(date '+%Y-%m-%d %H:%M:%S')" >> "$ssh_backup_dir/README.md"
            echo "# WARNING: Contains public keys only - DO NOT COMMIT" >> "$ssh_backup_dir/README.md"
            echo "" >> "$ssh_backup_dir/README.md"
            echo "## Public Keys" >> "$ssh_backup_dir/README.md"
            for key in "$ssh_backup_dir"/*.pub; do
                if [ -f "$key" ]; then
                    echo "### $(basename "$key")" >> "$ssh_backup_dir/README.md"
                    echo '```' >> "$ssh_backup_dir/README.md"
                    cat "$key" >> "$ssh_backup_dir/README.md"
                    echo '' >> "$ssh_backup_dir/README.md"
                    echo '```' >> "$ssh_backup_dir/README.md"
                    echo "" >> "$ssh_backup_dir/README.md"
                fi
            done
            print_success "SSH backup created: $ssh_backup_dir"
            backup_count=$((backup_count + 1))
        else
            print_warning "No SSH keys found - you'll need to generate new ones on the new machine"
        fi
    else
        print_warning "~/.ssh directory not found"
    fi

    # ==========================================================================
    # 4. 其他重要配置备份
    # ==========================================================================
    print_warning "Backing up other configurations..."

    if [ -L "$HOME/.1password/agent.sock" ]; then
        echo "# 1Password SSH Agent" > "$WORKING_DIR/.1password_config.txt"
        echo "Symlink: ~/.1password/agent.sock -> $(readlink "$HOME/.1password/agent.sock")" >> "$WORKING_DIR/.1password_config.txt"
        echo "# Setup on new machine:" >> "$WORKING_DIR/.1password_config.txt"
        echo "# 1. Install 1Password" >> "$WORKING_DIR/.1password_config.txt"
        echo "# 2. mkdir -p ~/.1password" >> "$WORKING_DIR/.1password_config.txt"
        echo "# 3. ln -s ~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock ~/.1password/agent.sock" >> "$WORKING_DIR/.1password_config.txt"
        print_success "1Password config documented"
        backup_count=$((backup_count + 1))
    fi

    if [ -f "$HOME/.kube/config" ]; then
        echo "# Kubernetes Contexts Backup" > "$WORKING_DIR/.kube_contexts.txt"
        echo "# Generated: $(date '+%Y-%m-%d %H:%M:%S')" >> "$WORKING_DIR/.kube_contexts.txt"
        echo "# WARNING: Context names only - NOT the actual config" >> "$WORKING_DIR/.kube_contexts.txt"
        echo "" >> "$WORKING_DIR/.kube_contexts.txt"
        echo "## Available Contexts:" >> "$WORKING_DIR/.kube_contexts.txt"
        kubectl config get-contexts -o name 2>/dev/null >> "$WORKING_DIR/.kube_contexts.txt" || echo "Could not list contexts" >> "$WORKING_DIR/.kube_contexts.txt"
        echo "" >> "$WORKING_DIR/.kube_contexts.txt"
        echo "## To restore:" >> "$WORKING_DIR/.kube_contexts.txt"
        echo "# Copy your kubeconfig from old machine or get from your team" >> "$WORKING_DIR/.kube_contexts.txt"
        print_success "Kubernetes contexts documented"
        backup_count=$((backup_count + 1))
    fi

    if command_exists code; then
        echo "# VSCode Extensions Backup" > "$WORKING_DIR/.vscode_extensions.txt"
        echo "# Generated: $(date '+%Y-%m-%d %H:%M:%S')" >> "$WORKING_DIR/.vscode_extensions.txt"
        echo "# To restore: code --install-extension <extension-id>" >> "$WORKING_DIR/.vscode_extensions.txt"
        echo "" >> "$WORKING_DIR/.vscode_extensions.txt"
        code --list-extensions >> "$WORKING_DIR/.vscode_extensions.txt" 2>/dev/null || echo "Could not list extensions" >> "$WORKING_DIR/.vscode_extensions.txt"
        print_success "VSCode extensions documented"
        backup_count=$((backup_count + 1))
    fi

    # ==========================================================================
    # 5. 生成备份报告
    # ==========================================================================
    print_header "Backup Summary"

    local backup_report="$WORKING_DIR/.backup_report_$(date +%Y%m%d_%H%M%S).md"
    cat > "$backup_report" << EOF
# Dotfiles Backup Report

**Generated**: $(date '+%Y-%m-%d %H:%M:%S')
**Machine**: $(hostname)
**User**: $(whoami)

## Backup Items

| Item | Status |
|------|--------|
| Brewfile | $([ -f "$WORKING_DIR/Brewfile" ] && echo "✅ Saved" || echo "❌ Failed") |
| Git config summary | $([ -f "$WORKING_DIR/.git_config_summary.txt" ] && echo "✅ Saved" || echo "❌ Failed") |
| SSH public keys | $([ -d "$ssh_backup_dir" ] && echo "✅ Saved to $ssh_backup_dir" || echo "⚠️ Not found") |
| 1Password config | $([ -f "$WORKING_DIR/.1password_config.txt" ] && echo "✅ Documented" || echo "⚠️ Not configured") |
| Kubernetes contexts | $([ -f "$WORKING_DIR/.kube_contexts.txt" ] && echo "✅ Documented" || echo "⚠️ Not configured") |
| VSCode extensions | $([ -f "$WORKING_DIR/.vscode_extensions.txt" ] && echo "✅ Documented" || echo "⚠️ Not installed") |

## Files Created

- Brewfile (updated)
- .git_config_summary.txt ⚠️ DO NOT COMMIT
- .1password_config.txt
- .kube_contexts.txt
- .vscode_extensions.txt
$( [ -d "$ssh_backup_dir" ] && echo "- $ssh_backup_dir/ ⚠️ DO NOT COMMIT" )

## Next Steps

1. Review changes: git status
2. Commit safe files: git add Brewfile .1password_config.txt .kube_contexts.txt .vscode_extensions.txt
3. git commit -m 'backup: update dotfiles'
4. ⚠️ DO NOT commit: .git_config_summary.txt, ssh_backup_*/
EOF

    print_success "Backup report generated: $backup_report"

    echo ""
    echo "=========================================="
    echo "Backup Summary"
    echo "=========================================="
    echo "  Items backed up: $backup_count"
    echo "  Warnings: $backup_warnings"
    echo ""
    echo "Files to review:"
    echo "  ✅ Safe to commit: Brewfile, .1password_config.txt, .kube_contexts.txt, .vscode_extensions.txt"
    echo "  ⚠️  DO NOT COMMIT: .git_config_summary.txt, ssh_backup_*/"
    echo ""
    echo "Next steps:"
    echo "  1. Review: git status"
    echo "  2. Commit safe files: git add Brewfile .1password_config.txt .kube_contexts.txt .vscode_extensions.txt"
    echo "  3. git commit -m 'backup: update dotfiles'"
    echo "=========================================="
}
function cmd_sync() {
    print_header "Syncing from Git"

    if [ ! -d "$DOTFILES_DIR/.git" ]; then
        print_error "Not a git repository: $DOTFILES_DIR"
        return 1
    fi

    cd "$DOTFILES_DIR"

    # Pull latest changes
    print_warning "Pulling latest changes..."
    git pull origin main 2>/dev/null || git pull 2>/dev/null || true
    print_success "Synced"

    # Check for placeholder config
    if grep -qE "YOUR_NAME|YOUR_EMAIL" "$DOTFILES_DIR/git/config" 2>/dev/null; then
        print_warning "⚠️  git/config contains placeholder values!"
        echo "    Run: git config --file ~/.gitconfig user.name 'Your Name'"
        echo "    Run: git config --file ~/.gitconfig user.email 'your@email.com'"
        echo "    Run: git config --file ~/.gitconfig user.signingkey 'your-ssh-key'"
    fi

    print_header "Sync Complete!"
}

function cmd_full_recover() {
    print_header "Full Recovery (New Machine)"

    # Check for git
    if ! command_exists git; then
        print_error "Git not found. Please install Xcode Command Line Tools first."
        return 1
    fi

    # Check if this is a fresh clone or existing setup
    if [ ! -d "$DOTFILES_DIR/.git" ]; then
        print_warning "This doesn't appear to be a git clone."
        echo "Please clone your dotfiles repository first:"
        echo "  git clone <your-repo-url> $DOTFILES_DIR"
        return 1
    fi

    # Run init
    cmd_init

    # Run install
    cmd_install

    # Run sync
    cmd_sync

    print_header "Full Recovery Complete!"
    echo ""
    echo "IMPORTANT: Configure your personal settings:"
    echo ""
    echo "  # Git configuration"
    echo "  git config --file ~/.gitconfig user.name 'Your Name'"
    echo "  git config --file ~/.gitconfig user.email 'your@email.com'"
    echo "  git config --file ~/.gitconfig user.signingkey 'your-ssh-key'"
    echo ""
    echo "  # SSH config template is in ~/.dotfiles/ssh/example"
    echo "  # 1Password SSH agent symlink should exist at ~/.1password/agent.sock"
    echo "  # Generate new SSH keys"
    echo "  ssh-keygen -t ed25519 -C 'your@email.com'"
    echo ""
    echo "  # Install Homebrew packages"
    echo "  brew bundle install"
    echo ""
}

function cmd_check() {
    print_header "Checking Setup Status"

    local missing=0

    # Check Homebrew
    echo -n "Homebrew: "
    if command_exists brew; then
        print_success "installed ($(brew --version | head -1))"
    else
        print_error "not found"
        ((missing++))
    fi

    # Check zsh
    echo -n "Zsh: "
    if command_exists zsh; then
        print_success "installed ($(zsh --version))"
    else
        print_error "not found"
        ((missing++))
    fi

    # Check Neovim
    echo -n "Neovim: "
    if command_exists nvim; then
        print_success "installed ($(nvim --version | head -1))"
    else
        print_error "not found"
        ((missing++))
    fi

    # Check tmux
    echo -n "Tmux: "
    if command_exists tmux; then
        print_success "installed ($(tmux -V))"
    else
        print_error "not found"
        ((missing++))
    fi

    # Check antigen
    echo -n "Antigen: "
    if [ -f "$HOME/.antigen/antigen.zsh" ]; then
        print_success "installed"
    else
        print_error "not found"
        ((missing++))
    fi

    # Check symlinks
    echo ""
    echo "Symlinks:"
    for i in "${FILES[@]}"; do
        echo -n "  $i: "
        if [ -L "$HOME_DIR/$i" ]; then
            local target=$(readlink "$HOME_DIR/$i")
            if [[ "$target" == *"$WORKING_DIR"* ]]; then
                print_success "linked to dotfiles"
            else
                print_warning "linked elsewhere: $target"
            fi
        elif [ -f "$HOME_DIR/$i" ]; then
            print_warning "exists but not linked"
        else
            print_error "not found"
        fi
    done

    # Check git config
    echo ""
    echo "Git Config:"
    local git_name=$(git config --file "$HOME_DIR/.gitconfig" user.name 2>/dev/null || echo "")
    local git_email=$(git config --file "$HOME_DIR/.gitconfig" user.email 2>/dev/null || echo "")

    echo -n "  user.name: "
    if [[ "$git_name" == "YOUR_NAME" || -z "$git_name" ]]; then
        print_warning "not configured"
    else
        print_success "$git_name"
    fi

    echo -n "  user.email: "
    if [[ "$git_email" == "YOUR_EMAIL" || -z "$git_email" ]]; then
        print_warning "not configured"
    else
        print_success "$git_email"
    fi

    echo ""
    if [ $missing -eq 0 ]; then
        print_success "All checks passed!"
    else
        print_warning "$missing items need attention"
    fi
}

# =============================================================================
# Main
# =============================================================================

# Parse command
COMMAND="${1:-help}"

case "$COMMAND" in
    init)
        cmd_init
        ;;
    install)
        cmd_install
        ;;
    backup)
        cmd_backup
        ;;
    sync)
        cmd_sync
        ;;
    full-recover)
        cmd_full_recover
        ;;
    check)
        cmd_check
        ;;
    help|--help|-h)
        cmd_help
        ;;
    *)
        print_error "Unknown command: $COMMAND"
        echo "Run './setup.sh help' for usage"
        exit 1
        ;;
esac

exit 0
