# Dotfiles 备份说明

> 详细备份指南 - 离职前必读

---

## 📋 目录

1. [备份目的](#备份目的)
2. [备份内容](#备份内容)
3. [备份步骤](#备份步骤)
4. [备份后处理](#备份后处理)
5. [常见问题](#常见问题)

---

## 🎯 备份目的

离职前备份 dotfiles 的目的是：

- ✅ 保留开发环境配置
- ✅ 快速在新机器恢复工作环境
- ✅ 记录已安装的工具和扩展
- ✅ 保存 SSH 公钥（用于新机器授权）

---

## 📦 备份内容

### 自动备份（运行 `./setup.sh backup`）

| 项目 | 说明 | 敏感性 | 提交 |
|------|------|--------|------|
| **Brewfile** | Homebrew 包列表 | 公开 | ✅ |
| **SSH 公钥** | `~/.ssh/*.pub` | 公开 | ⚠️ |
| **Git 配置** | 用户信息 | 敏感 | ❌ |
| **1Password** | SSH Agent 配置 | 敏感 | ⚠️ |
| **VSCode** | 扩展列表 | 公开 | ✅ |

### 需要手动备份

- [ ] 浏览器书签
- [ ] 1Password 紧急工具包
- [ ] 其他应用配置

---

## 🚀 备份步骤

### 步骤 1: 运行备份脚本

```bash
cd ~/.dotfiles
./setup.sh backup
```

### 步骤 2: 查看备份报告

```bash
# 查看最新的备份报告
ls -lt .backup_report_*.md | head -1 | awk '{print $NF}' | xargs cat
```

备份报告会显示：
```
Backup Summary
==========================================
  Items backed up: 5
  Warnings: 0

Files to review:
  ✅ Safe to commit: Brewfile, .1password_config.txt, .vscode_extensions.txt
  ⚠️  DO NOT COMMIT: .git_config_summary.txt, ssh_backup_*/
```

### 步骤 3: 查看备份内容

```bash
# 查看 Brewfile 变更
git diff Brewfile

# 查看 Git 配置摘要（敏感！看完删除）
cat .git_config_summary.txt

# 查看 SSH 公钥
ls ssh_backup_*/
cat ssh_backup_*/id_ed25519.pub
```

### 步骤 4: 提交安全文件

```bash
# 只提交安全的文件
git add Brewfile
git commit -m 'backup: update dotfiles before leaving'
git push
```

### 步骤 5: 清理敏感文件

```bash
# 确认敏感文件已被 .gitignore 排除
git status

# 手动清理（可选）
rm -f .git_config_summary.txt
rm -rf ssh_backup_*/
rm -f .1password_config.txt
rm -f .vscode_extensions.txt
rm -f .backup_report_*.md
```

---

## 📝 备份后处理

### 验证备份完整性

```bash
# 1. 检查 Brewfile
head -20 Brewfile

# 2. 备份 SSH 公钥到安全位置
cp ssh_backup_*/id_ed25519.pub ~/Downloads/

# 3. 记录 Git 配置
git config --global user.name
git config --global user.email
```

### 保存备份报告

```bash
# 将备份报告保存到安全位置（不提交到 git）
cp .backup_report_*.md ~/Downloads/dotfiles-backup-$(date +%Y%m%d).md
```

---

## ❓ 常见问题

### Q1: 备份会包含我的 SSH 私钥吗？

**不会！** 备份只复制 `.pub` 公钥文件，私钥永远不会被复制或提交。

### Q2: 备份文件哪些可以提交到 Git？

| 文件 | 是否可提交 |
|------|-----------|
| Brewfile | ✅ |
| .git_config_summary.txt | ❌ 包含真实信息 |
| ssh_backup_*/ | ❌ 公钥也不提交 |
| .1password_config.txt | ⚠️ 仅配置说明 |
| .vscode_extensions.txt | ✅ |

### Q3: 如何确认敏感文件不会被提交？

```bash
# 运行备份后检查
git status

# 如果敏感文件出现在 "Untracked files" 中，说明已被 .gitignore 正确排除
```

### Q4: 备份后多久需要重新备份？

- **定期备份**: 每月一次
- **安装新工具后**: 立即备份
- **离职前**: 必须备份

### Q5: 如何验证备份有效？

在新机器或虚拟机上测试：

```bash
git clone <your-repo> ~/.dotfiles-test
cd ~/.dotfiles-test
./setup.sh check
```

---

## 🔐 安全清单

离职前确认：

- [ ] 备份已推送到 GitHub
- [ ] 敏感文件已从本地删除
- [ ] 已移除旧机器的 GitHub 授权
- [ ] 已移除旧机器的 1Password 授权
- [ ] 已更新重要账户密码

---

**祝你新工作顺利！** 🎉
