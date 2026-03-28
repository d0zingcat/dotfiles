# Dotfiles 迁移指南

> 个人备份说明 - 用于新机器配置参考
> 
> **创建时间**: 2026-03-04
> **适用场景**: 离职后新公司机器配置

---

## 📋 目录

1. [备份内容](#备份内容)
2. [不包含的内容](#不包含的内容)
3. [新机器配置步骤](#新机器配置步骤)
4. [常见问题](#常见问题)
5. [个性化配置](#个性化配置)

---

## 📦 备份内容

### 已备份到 Git 仓库

| 文件/目录 | 说明 | 用途 |
|-----------|------|------|
| `.zshrc` | Shell 配置 | 60+ alias 和函数 |
| `.tmux.conf` | Tmux 配置 | 终端复用 |
| `git/config` | Git 配置模板 | 全局 Git 设置（占位符） |
| `nvim/` | Neovim 配置 | 编辑器配置 |
| `wezterm/` | WezTerm 配置 | 终端模拟器 |
| `alacritty/` | Alacritty 配置 | 备用终端 |
| `ghostty/` | Ghostty 配置 | 现代终端 |
| `starship.toml` | Starship 配置 | Shell 提示符 |
| `Brewfile` | Homebrew 包列表 | 所有工具和应用 |
| `setup.sh` | 安装脚本 | 一键配置 |
| `ssh/example` | SSH 配置模板 | 初始化 `~/.ssh/config` |
| `CHECKLIST.md` | 检查清单 | 配置验证 |
| `QUICKSTART.md` | 快速开始 | 3-5 分钟配置 |
| `README.md` | 完整文档 | 使用说明 |

### .gitignore 排除规则

以下敏感数据**不会被提交**，需要在新机器重新配置：

```
.ssh/              # SSH 密钥
.1password/        # 1Password 配置
.kube/             # Kubernetes 配置
*.env              # 环境变量
credentials.json   # 凭据文件
secrets.txt        # 密钥文件
```

---

## 🚫 不包含的内容

以下数据需要**手动迁移**或**重新配置**：

### 需要重新生成的

- [ ] SSH 密钥对 (`~/.ssh/id_ed25519`)
- [ ] GPG 密钥（如果使用）
- [ ] Git 签名密钥

### 需要重新配置的

- [ ] Git 用户信息 (name, email)
- [ ] 1Password SSH Agent
- [ ] Kubeconfig (工作集群配置)
- [ ] SSH config 中的自定义主机条目（如需额外调整）

### 需要单独备份的

- [ ] 浏览器书签
- [ ] 应用许可证
- [ ] 其他个人数据

---

## 🚀 新机器配置步骤

### 步骤 1: 克隆仓库

```bash
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles
```

### 步骤 2: 运行一键恢复

```bash
./setup.sh full-recover
```

这将自动完成：
- ✅ Xcode Command Line Tools 安装
- ✅ Homebrew 安装
- ✅ zsh antigen 安装
- ✅ asdf 版本管理器安装
- ✅ dotfiles 软链接创建
- ✅ 如 `~/.ssh/config` 不存在，则用模板初始化
- ✅ Git 基础配置
- ✅ fzf 安装

### 步骤 3: 配置个人信息

#### Git 配置

```bash
# 替换为你的真实信息
git config --file ~/.gitconfig user.name "Your Name"
git config --file ~/.gitconfig user.email "your@email.com"
git config --file ~/.gitconfig user.signingkey "your-ssh-public-key"
```

#### SSH 密钥生成

```bash
# 生成新密钥
ssh-keygen -t ed25519 -C "your@email.com"

# 查看公钥
cat ~/.ssh/id_ed25519.pub

# 添加到 GitHub/GitLab
# 1. 复制公钥: cat ~/.ssh/id_ed25519.pub | pbcopy
# 2. 粘贴到 GitHub: Settings → SSH and GPG keys → New SSH key
```

#### 1Password SSH Agent (如果使用)

```bash
# 如果 install 没自动创建，再手动创建符号链接
mkdir -p ~/.1password
ln -s ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock ~/.1password/agent.sock

# 添加 SSH 密钥到 1Password
op ssh add ~/.ssh/id_ed25519
```

### 步骤 4: 安装 Homebrew 包

```bash
# 安装所有包和应用
brew bundle install
```

这会安装：
- CLI 工具 (bat, ripgrep, fzf, lsd, difftastic)
- 开发语言 (go, rustup, node, lua, bun, uv)
- 数据库 (mysql, postgresql, redis)
- Mac 应用 (1Password, Ghostty, Cursor, Obsidian, etc.)
- VSCode 扩展

### 步骤 5: 验证安装

```bash
# 运行检查脚本
./setup.sh check
```

预期输出：
```
Homebrew: ✓ installed
Zsh: ✓ installed
Neovim: ✓ installed
Tmux: ✓ installed
Antigen: ✓ installed
```

### 步骤 6: 重启终端

```bash
# 重启终端或重新加载配置
source ~/.zshrc
```

---

## ❓ 常见问题

### Q1: zsh 配置不生效

```bash
# 重新加载配置
source ~/.zshrc

# 或重启终端
```

### Q2: Neovim 插件报错

```bash
# 同步所有插件
nvim --headless "+Lazy! sync" +qa

# 或打开 Neovim 后运行 :Lazy sync
```

### Q3: Homebrew 权限问题

```bash
# 修复权限
sudo chown -R $(whoami) $(brew --prefix)
```

### Q4: Git 签名失败

```bash
# 检查 1Password SSH agent
ls -la ~/.1password/agent.sock

# 列出已添加的密钥
op ssh list

# 如果没有密钥，添加它
op ssh add ~/.ssh/id_ed25519
```

### Q5: Antigen 插件加载慢

```bash
# 更新 antigen
antigen selfupdate

# 更新所有插件
antigen update

# 清理缓存
antigen reset
antigen apply
```

### Q6: Tmux 插件未安装

```bash
# 在 tmux 中按下 Ctrl-a + I (大写的 i)
# 这会安装 TPM 插件
```

---

## ⚙️ 个性化配置

### 修改 Git 配置

仓库中的 `git/config` 只作为模板使用。机器上的实际配置请直接修改 `~/.gitconfig`：

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

### 添加新 alias

编辑 `~/.dotfiles/.zshrc`，在 alias 区域添加：

```zsh
alias myalias='command'
```

然后运行 `source ~/.zshrc`

### 添加 Homebrew 包

编辑 `~/.dotfiles/Brewfile`，添加：

```ruby
brew "package-name"
cask "app-name"
```

然后运行 `brew bundle install`

### 修改 Neovim 配置

编辑 `~/.dotfiles/nvim/lua/plugins/` 下的文件。

---

## 📞 需要帮助？

- 查看 [README.md](./README.md) 获取完整文档
- 查看 [CHECKLIST.md](./CHECKLIST.md) 获取检查清单
- 查看 [QUICKSTART.md](./QUICKSTART.md) 获取快速开始
- 运行 `./setup.sh help` 查看命令说明

---

## 📝 配置记录

### 当前配置

| 项目 | 值 |
|------|-----|
| Shell | zsh + antigen + oh-my-zsh |
| 编辑器 | Neovim (lazy.nvim) |
| 终端 | WezTerm / Ghostty / Alacritty |
| 终端复用 | Tmux (TPM) |
| 提示符 | Starship |
| 版本管理 | asdf |

### 主要工具

- **语言**: Go, Rust, Node.js, Python, Lua, Bun
- **K8s**: kubectl, k9s, helm, kubectx
- **数据库**: MySQL, PostgreSQL, Redis
- **Git**: SSH 签名 (1Password)

---

## 🔐 安全提醒

1. **不要提交敏感数据** - 所有敏感路径已在 `.gitignore` 中排除
2. **新机器重新生成密钥** - SSH、GPG 等密钥应该在新机器重新生成
3. **移除旧机器授权** - 离职前移除旧机器的 GitHub、1Password 授权
4. **更新密码** - 如果可能，更新重要账户的密码

---

**祝新工作顺利！** 🎉

---

## 💾 离职前备份流程

### 1. 运行备份脚本

```bash
cd ~/.dotfiles
./setup.sh backup
```

### 2. 备份输出说明

备份完成后会生成以下文件：

| 文件 | 内容 | 是否提交 |
|------|------|----------|
| `Brewfile` | Homebrew 包列表 | ✅ |
| `.git_config_summary.txt` | Git 配置（包含真实信息） | ⚠️ **不要** |
| `ssh_backup_YYYYMMDD_HHMMSS/` | SSH 公钥 | ⚠️ **不要** |
| `.1password_config.txt` | 1Password 设置 | ✅ |
| `.vscode_extensions.txt` | VSCode 扩展 | ✅ |
| `.backup_report_*.md` | 备份报告 | ✅ |

### 3. 查看备份报告

```bash
# 查看最新的备份报告
cat .backup_report_*.md | tail -50
```

备份报告会显示：
- ✅ 已备份的项目
- ⚠️ 未找到的配置
- 📝 下一步操作建议

### 4. 提交备份

```bash
# 查看变更
git status

# 提交安全文件
git add Brewfile .1password_config.txt .vscode_extensions.txt
git commit -m 'backup: pre-leaving dotfiles backup'
git push
```

### 5. 清理敏感文件

```bash
# 确认敏感文件已被 .gitignore 排除
git status --porcelain | grep -E "(summary|ssh_backup)"

# 如果没有输出，说明已正确排除
```

### 6. 额外备份建议

- [ ] **导出浏览器书签** (Chrome/Fi refox/Safari)
- [ ] **备份 1Password 紧急工具包**
- [ ] **记录常用 SSH 主机配置**
- [ ] **导出 Kubeconfig** (如果允许)
- [ ] **备份其他应用配置** (Raycast, Obsidian 等)

---

## 🔐 安全提醒

### 不要提交的文件

以下文件包含敏感信息，已在 `.gitignore` 中排除：

```
.git_config_summary.txt    # Git 真实配置
ssh_backup_*/              # SSH 公钥
.1password_config.txt      # 1Password 配置
.backup_report_*.md        # 备份报告
```

### 离职前检查

- [ ] **移除旧机器授权**: GitHub → Settings → Devices
- [ ] **移除 1Password 授权**: 1Password → Settings → Security
- [ ] **更新重要账户密码**
- [ ] **备份个人 SSH 公钥** (用于新机器)

---
