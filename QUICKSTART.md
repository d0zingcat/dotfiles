# 快速开始指南

> 3-5 分钟完成新机器基础配置

---

## 步骤 1: 克隆仓库 (1 分钟)

```bash
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles
```

---

## 步骤 2: 运行一键恢复 (2-3 分钟)

```bash
./setup.sh full-recover
```

这将自动完成：
- ✅ Xcode Command Line Tools 安装
- ✅ Homebrew 安装
- ✅ zsh antigen 安装
- ✅ dotfiles 软链接创建
- ✅ Git 基础配置

---

## 步骤 3: 配置个人信息 (1 分钟)

```bash
# Git 配置
git config --file ~/.gitconfig user.name "Your Name"
git config --file ~/.gitconfig user.email "your@email.com"

# SSH 密钥
ssh-keygen -t ed25519 -C "your@email.com"
```

---

## 步骤 4: 安装 Homebrew 包 (后台运行)

```bash
brew bundle install
```

这会安装所有 CLI 工具和应用程序。

---

## 步骤 5: 验证安装

```bash
./setup.sh check
```

---

## ✅ 完成！

重启终端或运行 `source ~/.zshrc` 即可开始使用。

---

## 下一步

- [ ] 添加 SSH 公钥到 GitHub/GitLab
- [ ] 配置 1Password SSH Agent
- [ ] 配置工作特定的 kubeconfig
- [ ] 安装个人应用 (Chrome, Slack, etc.)

---

## 常用命令

```bash
# 查看帮助
./setup.sh help

# 检查状态
./setup.sh check

# 同步最新配置
./setup.sh sync

# 备份当前配置
./setup.sh backup
```
