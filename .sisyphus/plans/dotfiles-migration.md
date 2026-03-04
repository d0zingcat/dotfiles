# Dotfiles 迁移计划

## TL;DR

> **目标**: 完善 dotfiles 仓库，使其能够通过 Git 同步方式迁移到新 Mac
> 
> **核心改进**:
> - 敏感数据排除机制 (.gitignore 完善)
> - Git 配置模板化 (自动提示新机器配置)
> - 增强 setup.sh 脚本 (一键初始化)
> - 完整文档 (README + 迁移指南)
>
> **交付物**: 4 个文件修改/创建 + 1 个文档
> **预估工作量**: 约 60 分钟

---

## Context

### 用户需求确认
- **新机器**: 全新 Mac (需要完整安装所有工具)
- **敏感数据**: 不迁移，重新配置 (SSH、1Password、Git 签名密钥)
- **迁移方式**: Git 仓库同步

### 当前状态分析

**已包含配置**:
| 文件 | 说明 |
|------|------|
| `.zshrc` | Shell 配置 (286 行，60+ alias/函数) |
| `.tmux.conf` | tmux 配置 (124 行) |
| `git/config` | ⚠️ 包含真实用户信息 |
| `nvim/` | Neovim 完整配置 (27 Lua 文件) |
| `wezterm/`, `alacritty/`, `ghostty/` | 终端配置 |
| `starship.toml` | Shell 提示符 |
| `Brewfile` | Homebrew 包 (180 行) |
| `setup.sh` | ⚠️ 功能不完整 |

**问题点**:
1. `git/config` 包含 name/email/signingkey - 需要模板化
2. `.zshrc` 包含工作函数需要标记区分
3. `.gitignore` 不够完善
4. `setup.sh` 缺少完整初始化流程

---

## Work Objectives

### 必须完成
1. **完善 .gitignore** - 添加敏感数据排除模式
2. **模板化 git/config** - 替换为占位符，添加初始化提示
3. **增强 setup.sh** - 添加完整的新机器初始化流程
4. **完善 README.md** - 添加使用说明和迁移指南

### 交付定义
- [ ] `.gitignore` 包含完整的敏感数据排除
- [ ] `git/config` 模板化，可自动检测并提示配置
- [ ] `setup.sh` 包含 `init`, `install`, `backup`, `sync` 子命令
- [ ] `README.md` 包含完整的使用文档

---

## Execution Strategy

### 任务依赖关系

```
Wave 1 (基础工作 - 可并行):
├── T1: 完善 .gitignore
├── T2: 模板化 git/config
└── T3: 标记 .zshrc 工作函数

Wave 2 (核心功能):
├── T4: 增强 setup.sh 脚本
└── T5: 创建迁移检查清单

Wave 3 (文档):
├── T6: 完善 README.md
└── T7: 创建快速开始指南

Wave FINAL:
└── T8: 整体验证和清理
```

---

## TODOs

---

- [ ] 1. 完善 .gitignore

  **What to do**:
  - 读取现有 `.gitignore`
  - 添加敏感数据排除模式:
    - SSH: `.ssh/` (已存在)
    - 1Password: `.1password/`
    - Kubeconfig: `.kube/`
    - 环境变量: `*.env`, `.env*`
    - 缓存: `__pycache__`, `.cache/`, `node_modules/`
    - IDE: `.idea/`, `.vscode/`
    - Mac: `.DS_Store`, `*.swp`
    - 临时文件: `*.tmp`, `*.log`
  - 确保不排除核心配置文件

  **Must NOT do**:
  - 移除已有的有效排除规则
  - 排除核心配置文件

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []
  - Justification: 简单的文件编辑任务

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with T2, T3)
  - **Blocks**: T4 (setup.sh 会使用这些规则)
  - **Blocked By**: None

  **Acceptance Criteria**:
  - [ ] 新增的排除模式覆盖所有已知敏感路径
  - [ ] 不影响核心配置文件同步
  - [ ] git status 显示合理的未跟踪文件列表

  **Evidence to Capture**:
  - [ ] `.gitignore` 文件 diff

---

- [ ] 2. 模板化 git/config

  **What to do**:
  - 读取现有 `git/config`
  - 替换真实信息为占位符:
    - `user.name` → `YOUR_NAME`
    - `user.email` → `YOUR_EMAIL`
    - `user.signingkey` → `YOUR_SSH_SIGNING_KEY`
  - 添加自动检测和提示脚本:
    - 检测是否未配置
    - 提示用户运行配置命令
  - 保持其他有效配置不变

  **Must NOT do**:
  - 破坏现有的 Git 功能配置
  - 移除 diff/merge 工具配置

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []
  - Justification: 简单的模板替换任务

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with T1, T3)
  - **Blocks**: T4
  - **Blocked By**: None

  **Acceptance Criteria**:
  - [ ] 真实用户信息被替换为占位符
  - [ ] 添加配置检测逻辑
  - [ ] 脚本可正确检测未配置状态

  **Evidence to Capture**:
  - [ ] `git/config` 文件内容

---

- [ ] 3. 标记 .zshrc 工作函数

  **What to do**:
  - 读取 `.zshrc`
  - 为工作相关函数添加标记注释:
    - `klogs`, `bitnami_seal` → Kubernetes 相关
    - `rsync_work`, `replace_remote` → 工作环境相关
    - `git_config_work`, `git_config_play` → 多环境 Git
  - 添加"工作函数"区块注释块
  - 在文件头部添加说明

  **Must NOT do**:
  - 修改任何函数逻辑
  - 删除任何功能
  - 改变现有的 alias 行为

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []
  - Justification: 纯注释编辑任务

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with T1, T2)
  - **Blocks**: T4
  - **Blocked By**: None

  **Acceptance Criteria**:
  - [ ] 工作函数被清晰标记
  - [ ] 文件头部有说明注释
  - [ ] 逻辑未改变

  **Evidence to Capture**:
  - [ ] `.zshrc` diff 显示新增注释

---

- [ ] 4. 增强 setup.sh 脚本

  **What to do**:
  - 读取现有 `setup.sh`
  - 添加/完善以下函数:
    - `init`: 全新系统安装 (Homebrew, Xcode, 基础工具)
    - `install`: 安装 dotfiles 软链接
    - `backup`: 导出当前配置到 dotfiles 仓库
    - `sync`: 从 Git 恢复配置
    - `full-recover`: 完整新机器初始化 (init + install)
  - 添加参数解析
  - 添加环境检测
  - 添加进度提示
  - 添加回滚能力

  **Must NOT do**:
  - 破坏现有功能
  - 删除现有的 recover 函数

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
  - **Skills**: []
  - Justification: 需要编写完整的 shell 脚本逻辑

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 2
  - **Blocks**: None
  - **Blocked By**: T1, T2, T3 (依赖 .gitignore 完善)

  **Acceptance Criteria**:
  - [ ] `setup.sh init` 可执行全新系统安装
  - [ ] `setup.sh install` 可建立软链接
  - [ ] `setup.sh backup` 可导出配置
  - [ ] `setup.sh sync` 可从 Git 恢复
  - [ ] `setup.sh full-recover` 可一键初始化
  - [ ] 脚本有完善的错误处理

  **Evidence to Capture**:
  - [ ] setup.sh 完整内容
  - [ ] 测试脚本可执行性

---

- [ ] 5. 创建迁移检查清单

  **What to do**:
  - 创建 `CHECKLIST.md` 文件
  - 包含新机器配置检查清单:
    - 系统设置 (Xcode, Command Line Tools)
    - Homebrew 安装
    - dotfiles 同步
    - 1Password 配置
    - SSH 密钥生成
    - Git 配置
    - Kubernetes 配置
    - 验证步骤
  - 每个项目标记为自动/手动

  **Must NOT do**:
  - 包含实际敏感数据

  **Recommended Agent Profile**:
  - **Category**: `writing`
  - **Skills**: []
  - Justification: 文档编写任务

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with T4)
  - **Blocks**: T6
  - **Blocked By**: T1, T2, T3

  **Acceptance Criteria**:
  - [ ] 检查清单覆盖完整迁移流程
  - [ ] 区分自动和手动步骤
  - [ ] 包含验证命令

  **Evidence to Capture**:
  - [ ] CHECKLIST.md 文件

---

- [ ] 6. 完善 README.md

  **What to do**:
  - 读取现有 README.md
  - 重写为完整的文档:
    - 简介
    - 安装/快速开始
    - 各个组件说明
    - 迁移指南
    - 故障排查
    - 贡献方式 (如果有)
  - 包含目录导航

  **Must NOT do**:
  - 破坏现有 README 结构（如果有效）

  **Recommended Agent Profile**:
  - **Category**: `writing`
  - **Skills**: []
  - Justification: 技术文档编写

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 3
  - **Blocks**: None
  - **Blocked By**: T5 (CHECKLIST)

  **Acceptance Criteria**:
  - [ ] 包含完整使用说明
  - [ ] 包含迁移步骤
  - [ ] 可读性强

  **Evidence to Capture**:
  - [ ] README.md 更新内容

---

- [ ] 7. 创建快速开始指南

  **What to do**:
  - 创建 `QUICKSTART.md` 简明指南
  - 包含 3 步快速开始:
    1. 克隆仓库
    2. 运行初始化
    3. 配置个人信息
  - 包含最常用的命令

  **Must NOT do**:
  - 包含过多细节

  **Recommended Agent Profile**:
  - **Category**: `writing`
  - **Skills**: []
  - Justification: 简单文档

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with T6)
  - **Blocks**: None
  - **Blocked By**: T5

  **Acceptance Criteria**:
  - [ ] 3-5 分钟可完成基础配置
  - [ ] 包含所有必要步骤

  **Evidence to Capture**:
  - [ ] QUICKSTART.md 文件

---

- [ ] 8. 整体验证和清理

  **What to do**:
  - 运行 git status 检查所有变更
  - 验证所有修改的文件语法正确
  - 确保敏感数据未被提交
  - 清理临时文件

  **Must NOT do**:
  - 遗漏任何问题

  **Recommended Agent Profile**:
  - **Category**: `unspecified-low`
  - **Skills**: []
  - Justification: 验证性任务

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave FINAL
  - **Blocks**: None
  - **Blocked By**: T1-T7

  **Acceptance Criteria**:
  - [ ] 所有文件变更已保存
  - [ ] 无敏感数据泄漏
  - [ ] 脚本可执行

  **Evidence to Capture**:
  - [ ] git status 输出
  - [ ] 最终文件列表

---

## Final Verification Wave

### 验证清单
- [ ] `.gitignore` 包含所有敏感路径
- [ ] `git/config` 不包含真实用户信息
- [ ] `setup.sh` 所有子命令可用
- [ ] README.md 完整可用
- [ ] CHECKLIST.md 覆盖完整流程
- [ ] 无临时文件遗留

---

## Success Criteria

### 验证命令
```bash
# 检查敏感数据排除
git status --porcelain | grep -E "\.(env|ssh|key)" || echo "No sensitive files staged"

# 检查脚本可执行
./setup.sh --help

# 检查 README
cat README.md | head -20
```

### 交付检查
- [ ] 所有 TODO 完成
- [ ] 文档完整
- [ ] 脚本功能正常
- [ ] 敏感数据已排除

---

## Commit Strategy

单个提交包含所有变更:
- Message: `chore: 完善 dotfiles 迁移功能`
- Files: 所有修改的文件
- Pre-commit: 无 (dotfiles 仓库特性)

---

## 补充说明

### 后续步骤 (用户自行执行)
1. 在新机器上克隆仓库
2. 运行 `setup.sh full-recover`
3. 配置个人信息 (Git, SSH, 1Password)
4. 验证所有工具正常工作

### 需要手动配置的项目
- Git 用户信息 (name, email, signingkey)
- SSH 密钥 (需要重新生成)
- 1Password SSH agent (需要在新机器上配置)
- Kubeconfig (工作相关，不包含在 dotfiles 中)
- 特定工作环境的 alias 和函数