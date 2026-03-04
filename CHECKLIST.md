# Dotfiles 迁移检查清单

> 用于新机器环境设置的完整检查清单
> 
> **自动** = 脚本自动完成 | **手动** = 需要用户操作

---

## 📋 准备工作

- [ ] **手动** 确认新 Mac 已登录 Apple ID
- [ ] **手动** 安装 1Password (从 Mac App Store 或 1password.com)
- [ ] **手动** 配置 1Password SSH Agent (System Settings → 1Password → Developer)

---

## 🚀 系统初始化 (自动)

运行：`./setup.sh init`

- [ ] **自动** Xcode Command Line Tools 安装
- [ ] **自动** Homebrew 安装
- [ ] **自动** zsh antigen 安装
- [ ] **自动** asdf 版本管理器安装
- [ ] **自动** 创建必要目录 (~/.config, ~/.ssh, ~/.kube)
- [ ] **自动** macOS 偏好设置 (禁用长按字符弹出)

---

## 📦 Dotfiles 安装 (自动)

运行：`./setup.sh install`

- [ ] **自动** .zshrc 软链接
- [ ] **自动** .tmux.conf 软链接
- [ ] **自动** ~/.config/git 软链接
- [ ] **自动** ~/.config/nvim 软链接
- [ ] **自动** ~/.config/tmux 软链接
- [ ] **自动** ~/.config/wezterm 软链接
- [ ] **自动** ~/.config/starship.toml 软链接
- [ ] **自动** ~/.gitconfig 软链接
- [ ] **自动** Git 全局配置 (excludesfile, defaultBranch)
- [ ] **自动** fzf 安装和配置

---

## ⚙️ 个人配置 (手动 - 重要!)

### Git 配置
```bash
# 替换为你的真实信息
git config --file ~/.gitconfig user.name "Your Name"
git config --file ~/.gitconfig user.email "your@email.com"
git config --file ~/.gitconfig user.signingkey "your-ssh-public-key"
```

- [ ] **手动** 配置 user.name
- [ ] **手动** 配置 user.email
- [ ] **手动** 配置 user.signingkey

### SSH 密钥
```bash
# 生成新的 SSH 密钥
ssh-keygen -t ed25519 -C "your@email.com"

# 添加到 1Password SSH Agent
op ssh add ~/.ssh/id_ed25519

# 添加到 GitHub/GitLab
cat ~/.ssh/id_ed25519.pub | pbcopy
# 然后粘贴到 GitHub/GitLab 的 SSH Keys 设置
```

- [ ] **手动** 生成 SSH 密钥
- [ ] **手动** 添加密钥到 1Password
- [ ] **手动** 添加公钥到代码托管平台

### 验证 Git 配置
```bash
# 检查配置
git config --get user.name
git config --get user.email
git config --get user.signingkey

# 测试签名
git commit --allow-empty -m "Test signed commit"
git log -1 --format=full
```

- [ ] **手动** 验证配置正确
- [ ] **手动** 测试提交签名

---

## 🍺 Homebrew 包安装 (自动)

运行：`brew bundle install`

- [ ] **自动** 安装 CLI 工具 (bat, ripgrep, fzf, lsd, difftastic, etc.)
- [ ] **自动** 安装开发工具 (go, rustup, node, lua, luarocks, etc.)
- [ ] **自动** 安装 Kubernetes 工具 (kubectl, helm, k9s, kubectx, etc.)
- [ ] **自动** 安装数据库 (mysql, postgresql, redis, etc.)
- [ ] **自动** 安装 Mac 应用 (1Password, Ghostty, WezTerm, Cursor, etc.)
- [ ] **自动** 安装 VSCode 扩展
- [ ] **自动** 安装 Go 工具 (golangci-lint, gopls, delve, etc.)
- [ ] **自动** 安装 Cargo 工具 (sqlx-cli)

---

## 🔧 验证安装

### Shell 环境
```bash
# 重启 shell 或运行
source ~/.zshrc

# 验证常用命令
which nvim tmux fzf bat rg lsd
```

- [ ] **手动** source ~/.zshrc 无错误
- [ ] **手动** 验证 nvim 可用
- [ ] **手动** 验证 tmux 可用
- [ ] **手动** 验证常用 alias (l, la, lt, vi)

### Neovim
```bash
# 打开 Neovim
nvim

# 首次启动会自动安装插件
# 等待插件安装完成
:Lazy
```

- [ ] **手动** Neovim 启动无错误
- [ ] **自动** lazy.nvim 自动安装插件
- [ ] **手动** 验证 LSP 可用 (:LspInfo)
- [ ] **手动** 验证 treesitter 可用

### Kubernetes
```bash
# 验证 kubectl
kubectl version --client

# 验证 krew
kubectl krew version

# 验证常用工具
k9s version
```

- [ ] **手动** kubectl 可用
- [ ] **手动** k9s 可用
- [ ] **手动** 配置 kubeconfig (工作相关)

---

## 🏢 工作环境 (可选)

如果你有特定的工作环境需求：

- [ ] **手动** 配置 ~/.kube/config (工作集群)
- [ ] **手动** 配置 rsync_work 目标服务器
- [ ] **手动** 配置 git_config_work 邮箱
- [ ] **手动** 配置其他工作特定 alias

---

## ✅ 最终检查

运行：`./setup.sh check`

- [ ] **自动** Homebrew 检查
- [ ] **自动** Zsh 检查
- [ ] **自动** Neovim 检查
- [ ] **自动** Tmux 检查
- [ ] **自动** Antigen 检查
- [ ] **自动** Symlinks 检查
- [ ] **自动** Git Config 检查

---

## 📝 后续步骤

- [ ] **手动** 配置其他应用 (Raycast, Obsidian, etc.)
- [ ] **手动** 同步浏览器书签/扩展
- [ ] **手动** 配置工作专用软件
- [ ] **手动** 测试常用工作流

---

## 🔍 故障排查

### 常见问题

1. **zsh 配置不生效**
   ```bash
   source ~/.zshrc
   # 或重启终端
   ```

2. **Neovim 插件报错**
   ```bash
   nvim --headless "+Lazy! sync" +qa
   ```

3. **Homebrew 权限问题**
   ```bash
   sudo chown -R $(whoami) $(brew --prefix)
   ```

4. **Git 签名失败**
   ```bash
   # 检查 1Password SSH agent
   ls -la ~/.1password/agent.sock
   op ssh list
   ```

---

## 📞 需要帮助？

- 查看 README.md 获取详细文档
- 查看 setup.sh --help 获取命令说明
- 查看 .sisyphus/plans/dotfiles-migration.md 获取计划详情
