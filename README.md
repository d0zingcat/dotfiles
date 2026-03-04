# Dotfiles

> 个人 macOS 开发环境配置 - 支持一键迁移到新机器

---

## 🚀 快速开始

### 新机器设置 (推荐)

```bash
# 1. 克隆仓库
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles

# 2. 一键完整恢复
./setup.sh full-recover

# 3. 配置个人信息
git config --file ~/.gitconfig user.name "Your Name"
git config --file ~/.gitconfig user.email "your@email.com"
ssh-keygen -t ed25519 -C "your@email.com"

# 4. 安装 Homebrew 包
brew bundle install
```

### 现有机器设置

```bash
# 安装 dotfiles 软链接
./setup.sh install

# 检查当前状态
./setup.sh check
```

---

## 📋 命令说明

| 命令 | 说明 |
|------|------|
| `./setup.sh init` | 初始化新系统 (Homebrew, Xcode, antigen) |
| `./setup.sh install` | 安装 dotfiles 软链接 |
| `./setup.sh backup` | 备份当前配置到 Brewfile |
| `./setup.sh sync` | 从 git 仓库同步最新配置 |
| `./setup.sh full-recover` | 新机器完整恢复 (init + install + sync) |
| `./setup.sh check` | 检查当前安装状态 |
| `./setup.sh help` | 显示帮助信息 |

---

## 📁 目录结构

```
~/.dotfiles/
├── .gitignore          # Git 忽略规则 (敏感数据)
├── .tmux.conf          # Tmux 配置
├── .zshrc              # Zsh 配置 (alias + 函数)
├── Brewfile            # Homebrew 包列表
├── CHECKLIST.md        # 迁移检查清单
├── setup.sh            # 安装脚本
├── git/
│   ├── .gitignore      # Git 全局忽略
│   └── config          # Git 配置 (模板化)
├── nvim/               # Neovim 配置
│   ├── init.lua
│   └── lua/
├── wezterm/            # WezTerm 终端配置
├── alacritty/          # Alacritty 终端配置
├── ghostty/            # Ghostty 终端配置
├── starship.toml       # Starship 提示符
└── tmux/               # Tmux 插件 (TPM)
```

---

## 🔧 核心组件

### Shell (Zsh)

- **框架**: antigen + oh-my-zsh
- **插件**:
  - zsh-autosuggestions
  - zsh-syntax-highlighting
  - fzf-tab
  - vi-mode
- **特性**:
  - 60+ alias 和函数
  - Kubernetes 工具集成
  - Git 工作流优化
  - 工作环境标记

### 编辑器 (Neovim)

- **插件管理**: lazy.nvim
- **语言支持**: Go, Python, Rust, Lua
- **核心插件**:
  - LSP (lspconfig)
  - 自动补全 (nvim-cmp)
  - Treesitter (语法高亮)
  - Telescope (模糊搜索)
  - Snacks.nvim (UI 增强)
- **主题**: Tokyo Night

### 终端

- **WezTerm**: GPU 加速终端 (主要使用)
- **Alacritty**: 备用终端
- **Ghostty**: 现代化终端

### 终端复用 (Tmux)

- **前缀键**: `Ctrl-a`
- **插件**: TPM (Tmux Plugin Manager)
- **主题**: Dracula 配色
- **Vi 模式**: 复制/粘贴

### Kubernetes

- kubectl + krew
- k9s (TUI 管理)
- kubectx / kubens
- helm + helmfile
- ArgoCD CLI

---

## 📦 Homebrew 包

### CLI 工具

```bash
bat           # cat 替代
ripgrep       # grep 替代
lsd           # ls 替代
difftastic    # diff 工具
fzf           # 模糊搜索
```

### 开发语言

```bash
go            # Go 语言
rustup        # Rust
node          # Node.js
lua           # Lua
pnpm          # pnpm
bun           # Bun
uv            # Python uv
```

### 数据库

```bash
mysql         # MySQL
postgresql    # PostgreSQL
redis         # Redis
```

### Mac 应用

```bash
1password         # 密码管理
ghostty           # 终端
cursor            # 编辑器
obsidian          # 笔记
raycast           # 启动器
figma             # 设计
```

---

## ⚙️ 配置说明

### Git 配置模板

`git/config` 使用占位符，首次使用时需要配置：

```bash
git config --file ~/.gitconfig user.name "Your Name"
git config --file ~/.gitconfig user.email "your@email.com"
git config --file ~/.gitconfig user.signingkey "your-ssh-key"
```

### 工作环境函数

`.zshrc` 中包含工作环境相关的函数，已用 `# ==== WORK:` 标记：

- `klogs` - Kubernetes 日志查看
- `bitnami_seal` - Kubernetes 密钥加密
- `rsync_work` - 远程同步到工作服务器
- `replace_remote` - Git remote 切换
- `git_config_work` / `git_config_play` - 多环境 Git 配置

---

## 🔐 敏感数据

以下路径已被 `.gitignore` 排除，**不会被提交**：

- `.ssh/` - SSH 密钥
- `.1password/` - 1Password 配置
- `.kube/` - Kubernetes 配置
- `*.env` - 环境变量
- `credentials.json`, `secrets.txt` - 凭据

**需要在新机器上重新配置**。

---

## 🔄 迁移流程

### 从旧机器导出

```bash
cd ~/.dotfiles
./setup.sh backup
git add .
git commit -m "Update dotfiles before migration"
git push
```

### 在新机器恢复

```bash
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles
./setup.sh full-recover
```

详细步骤请参考 [CHECKLIST.md](./CHECKLIST.md)

---

## 🐛 故障排查

### zsh 配置不生效

```bash
source ~/.zshrc
# 或重启终端
```

### Neovim 插件报错

```bash
nvim --headless "+Lazy! sync" +qa
```

### Homebrew 权限问题

```bash
sudo chown -R $(whoami) $(brew --prefix)
```

### Git 签名失败

```bash
# 检查 1Password SSH agent
ls -la ~/.1password/agent.sock
op ssh list
```

---

## 📝 自定义

### 添加新包

编辑 `Brewfile`，然后运行：

```bash
brew bundle install
```

### 添加新 alias

编辑 `~/.dotfiles/.zshrc`，在 alias 区域添加：

```zsh
alias myalias='command'
```

### 添加 Neovim 插件

编辑 `~/.dotfiles/nvim/lua/plugins/` 下的文件。

---

## 📄 License

MIT

---

## 🔗 相关链接

- [迁移检查清单](./CHECKLIST.md)
- [Neovim 配置](./nvim/README.md)
- [Dotfiles 迁移计划](./.sisyphus/plans/dotfiles-migration.md)
