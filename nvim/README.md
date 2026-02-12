# Neovim 配置

这是一个基于 lazy.nvim 的 Neovim 配置，专注于 Python 和 Go 开发，提供现代化的编辑体验和高效的开发环境。

## 功能特点

- 🚀 基于 lazy.nvim 的插件管理
- 💻 完善的 LSP 支持，包括代码补全、诊断和代码操作
- 🔍 强大的语法高亮和代码分析 (Treesitter)
- 🧩 针对 Python 和 Go 开发的专业配置
- 🔧 内置调试支持 (DAP)
- 🎨 美观的 UI 和主题

## 目录结构

```
nvim/
├── init.lua              # 主配置入口
├── lua/
│   ├── core/             # 核心配置
│   │   ├── autocmds.lua  # 自动命令
│   │   ├── keymaps.lua   # 键位映射
│   │   ├── lazy.lua      # 插件管理器配置
│   │   └── options.lua   # 编辑器选项
│   └── plugins/          # 插件配置
│       ├── coding.lua    # 编码相关插件 (LSP, 补全)
│       ├── colorscheme.lua # 主题配置
│       ├── editor.lua    # 编辑器增强插件
│       ├── go.lua        # Go 开发专用插件
│       ├── python.lua    # Python 开发专用插件
│       ├── ui.lua        # UI 相关插件
│       └── utils.lua     # 实用工具插件
```

## 安装步骤

1. 备份现有配置（如果有）

```bash
mv ~/.config/nvim ~/.config/nvim.bak
```

2. 克隆此配置

```bash
git clone https://github.com/yourusername/nvim-config.git ~/.config/nvim
```

3. 启动 Neovim

```bash
nvim
```

首次启动时，lazy.nvim 将自动安装所有插件。

## 语言支持

### Python

- 语言服务器: Pyright 和 Ruff-LSP
- 代码格式化: Black 和 isort
- 调试: debugpy
- 虚拟环境管理: venv-selector
- 测试支持: pytest

### Go

- 语言服务器: gopls
- 代码格式化: gofumpt 和 goimports
- 调试: delve
- 工具集成: go.nvim
- 测试支持: Go 测试工具

## 主要快捷键

> 所有快捷键都基于 `<Space>` 作为 leader 键

### 通用

| 快捷键 | 功能 |
|--------|------|
| `<Space>ff` | 查找文件 |
| `<Space>fg` | 全局搜索 |
| `<Space>fb` | 浏览缓冲区 |
| `<Space>e` | 切换文件浏览器 |
| `<Space>w` | 保存文件 |
| `<Space>q` | 退出 |
| `<Space>h` | 清除搜索高亮 |
| `<Space>bd` | 删除缓冲区 |

### LSP 相关

| 快捷键 | 功能 |
|--------|------|
| `gd` | 转到定义 |
| `gr` | 查找引用 |
| `K` | 显示悬停信息 |
| `<Space>ca` | 代码操作 |
| `<Space>cr` | 重命名 |
| `<Space>cf` | 格式化代码 |
| `]d` | 下一个诊断 |
| `[d` | 上一个诊断 |

### Python 专用

| 快捷键 | 功能 |
|--------|------|
| `<Space>pv` | 选择 Python 虚拟环境 |
| `<Space>pt` | 运行最近的测试 |
| `<Space>pT` | 运行文件中的测试 |
| `<Space>pd` | 调试最近的测试 |

### Go 专用

| 快捷键 | 功能 |
|--------|------|
| `<Space>gtt` | 运行包测试 |
| `<Space>gtf` | 测试函数 |
| `<Space>gfs` | 填充结构体 |
| `<Space>gfa` | 添加标签 |
| `<Space>ge` | 生成错误处理 |
| `<Space>gr` | 运行 Go 程序 |

### 调试

| 快捷键 | 功能 |
|--------|------|
| `<Space>db` | 切换断点 |
| `<Space>dc` | 继续执行 |
| `<Space>di` | 单步进入 |
| `<Space>do` | 单步跳出 |
| `<Space>dO` | 单步跳过 |
| `<Space>dt` | 终止调试 |

## 自定义配置

您可以通过编辑以下文件来自定义配置：

- `lua/core/options.lua`: 修改编辑器选项
- `lua/core/keymaps.lua`: 添加或修改键位映射
- `lua/core/autocmds.lua`: 修改自动命令

## 疑难解答

如果遇到问题：

1. 确保 Neovim 版本 >= 0.9.0
2. 更新所有插件: `:Lazy update`
3. 检查健康状态: `:checkhealth`

## 依赖项

- Neovim >= 0.9.0
- Git
- 一个支持连字的 Nerd 字体 (推荐 JetBrainsMono Nerd Font)
- Node.js (用于某些 LSP 服务器)
- Python 3 (用于 Python 开发)
- Go (用于 Go 开发)
- ripgrep (用于全局搜索)

## 灵感来源

这个配置受到以下项目的启发：

- [LazyVim](https://github.com/LazyVim/LazyVim)
- [AstroNvim](https://github.com/AstroNvim/AstroNvim)
- [NvChad](https://github.com/NvChad/NvChad)

## 许可证

MIT 