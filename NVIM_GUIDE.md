# Neovim 配置使用手册

> **Leader 键 = `Space`（空格）**
> 任何时候按住 `Space` 稍等，**which-key** 会弹出所有可用提示菜单。

---

## 🚀 第一次启动

1. 打开 Neovim：`nvim`
2. lazy.nvim 自动安装所有插件（等待完成）
3. 重启 nvim，再运行 `:Lazy sync`
4. `:Mason` 查看工具安装状态
5. `:checkhealth` 检查环境健康

---

## 📁 文件树（neo-tree）

| 快捷键 | 功能 |
|--------|------|
| `<Space>e` | **打开/关闭文件树** |
| `<Space>o` | 聚焦到文件树 |
| `<Space>ge` | 浮动显示 Git 状态树 |

**文件树内操作：**

| 按键 | 功能 |
|------|------|
| `Enter` / `l` | 打开文件/展开目录 |
| `h` | 折叠目录 |
| `a` | 新建文件（末尾加 `/` 则创建目录） |
| `d` | 删除 |
| `r` | 重命名 |
| `y` | 复制 |
| `x` | 剪切 |
| `p` | 粘贴 |
| `q` | 关闭文件树 |

---

## 🔍 查找 / 搜索

| 快捷键 | 功能 |
|--------|------|
| `<Space>ff` | **查找文件** |
| `<Space>fr` | 最近打开的文件 |
| `<Space>fb` | 已打开的缓冲区 |
| `<Space>fg` | **全局内容搜索（grep）** |
| `<Space>fw` | 搜索光标下的单词 |
| `<Space>fh` | 搜索帮助文档 |
| `<Space>fk` | 查看所有快捷键 |
| `<Space>fs` | 当前文件符号 |
| `<Space>fS` | 工作区符号 |
| `<Space>fd` | 诊断错误 |
| `<Space>ft` | TODO 注释 |
| `<Space>sr` | **项目范围搜索替换**（grug-far） |

---

## 💡 LSP 代码智能

| 快捷键 | 功能 |
|--------|------|
| `gd` | **跳转到定义** |
| `gD` | 跳转到声明 |
| `gr` | 查看所有引用 |
| `gI` | 跳转到实现 |
| `gy` | 跳转到类型定义 |
| `K` | **悬浮显示文档** |
| `gK` | 函数签名帮助 |
| `<C-k>` | 签名帮助（插入模式） |
| `<Space>ca` | **代码操作**（自动修复、重构） |
| `<Space>cr` | **重命名符号**（实时预览） |
| `<Space>cd` | 显示当前行诊断详情 |
| `<Space>cl` | LSP 状态信息 |
| `<Space>cf` | **格式化**（文件或选中范围） |
| `<Space>uf` | 切换当前缓冲区自动格式化 |
| `<Space>uF` | 切换全局自动格式化 |
| `<Space>uh` | 切换 Inlay Hints |
| `]d` / `[d` | 跳到下/上一个诊断 |

---

## 🔴 诊断列表（Trouble）

| 快捷键 | 功能 |
|--------|------|
| `<Space>xx` | 工作区所有诊断 |
| `<Space>xX` | 当前文件诊断 |
| `<Space>xs` | 符号列表 |
| `<Space>xL` | 位置列表 |
| `<Space>xQ` | Quickfix 列表 |
| `]q` / `[q` | 在 Trouble 列表内跳转 |

---

## ✍️ 文本编辑增强

### 包围操作（mini.surround，前缀 `gs`）

| 快捷键 | 功能 | 示例 |
|--------|------|------|
| `gsa` | 添加包围 | `gsaiw"` = 用 `"` 包围单词 |
| `gsd` | 删除包围 | `gsd"` = 删除 `"` |
| `gsr` | 替换包围 | `gsr"'` = `"` 替换为 `'` |
| `gsf` | 向前查找包围 | |
| `gsh` | 高亮包围 | |

### 文本对象（mini.ai，在 d/c/y/v 后使用）

> `a` = around（含包围符号），`i` = inner（仅内容）

| 对象 | 说明 |
|------|------|
| `af` / `if` | 函数 |
| `ac` / `ic` | 类 |
| `aa` / `ia` | 参数 |
| `ab` / `ib` | 代码块 |
| `ae` / `ie` | 整个文件 |
| `aq` / `iq` | 引号 |
| `at` / `it` | HTML/JSX 标签 |

示例：`daf` 删除整个函数，`vif` 选中函数体，`caa` 修改整个参数

### 注释（`gc` 系列）

| 快捷键 | 功能 |
|--------|------|
| `gcc` | 行注释切换 |
| `gbc` | 块注释切换 |
| `gc{motion}` | 注释 motion 范围 |
| `gcO` / `gco` | 在上/下方插入注释 |

### 多光标（vim-visual-multi）

| 快捷键 | 功能 |
|--------|------|
| `<C-n>` | 选中光标下的词（重复按继续选下一个） |
| `<C-Down/Up>` | 向下/上添加光标 |
| `q` | 跳过当前，选下一个 |
| `<Esc>` | 退出多光标 |

---

## 🐛 调试（DAP）

| 快捷键 | 功能 |
|--------|------|
| `<Space>dc` | **开始/继续调试** |
| `<Space>db` | 切换断点 |
| `<Space>dB` | 条件断点 |
| `<Space>di` | 单步进入 |
| `<Space>do` | 单步跳出 |
| `<Space>dO` | 单步跳过 |
| `<Space>dC` | 运行到光标处 |
| `<Space>dt` | 终止调试 |
| `<Space>du` | 调试 UI 面板 |
| `<Space>dw` | 悬浮查看变量值 |
| `<Space>dr` | 打开 REPL |
| `<Space>dl` | 重新运行上次调试 |

---

## 🐹 Go 开发

| 快捷键 | 功能 |
|--------|------|
| `<Space>gr` | 运行 |
| `<Space>gb` | 构建 |
| `<Space>gv` | go vet |
| `<Space>gi` | 实现接口 |
| `<Space>gge` | 生成 if err 错误处理 |
| `<Space>ggf` | 填充结构体字段 |
| `<Space>ggs` | 填充 switch case |
| `<Space>gts` | 切换测试/实现文件 |
| `<Space>gtt` | 运行测试 |
| `<Space>gtf` | 测试当前函数 |
| `<Space>gtc` | 查看测试覆盖率 |
| `<Space>gta` | 添加 struct tag |
| `<Space>dtg` | 调试当前 Go 测试 |

---

## 🦀 Rust 开发

| 快捷键 | 功能 |
|--------|------|
| `<Space>rr` | 运行目标列表 |
| `<Space>rt` | 测试目标列表 |
| `<Space>rd` | 调试目标列表 |
| `<Space>re` | 解释错误 |
| `<Space>rm` | 展开宏 |
| `<Space>rc` | 打开 Cargo.toml |
| `<Space>rp` | 跳转到父模块 |
| `<Space>rx` | 打开外部文档 |
| `<Space>rcu` | 升级所有 crate 依赖 |
| `<Space>rco` | 查看 crate 信息 |

---

## 🐍 Python 开发

| 快捷键 | 功能 |
|--------|------|
| `<Space>pt` | 运行测试 |
| `<Space>pT` | 运行当前文件全部测试 |
| `<Space>pd` | DAP 调试测试 |
| `<Space>ps` | 停止测试 |
| `<Space>po` | 查看测试输出 |
| `<Space>pO` | 测试输出面板 |
| `<Space>pS` | 测试摘要面板 |
| `<Space>dpm` | 调试当前方法 |
| `<Space>dpc` | 调试当前类 |

---

## 📘 TypeScript/JavaScript 开发

| 快捷键 | 功能 |
|--------|------|
| `<Space>to` | 整理 import |
| `<Space>ta` | 添加缺失 import |
| `<Space>tu` | 删除未使用 import |
| `<Space>tf` | 修复所有问题 |
| `<Space>tr` | 重命名文件（自动更新引用） |
| `<Space>tR` | 查看文件引用 |

---

## 🌿 Git 操作

| 快捷键 | 功能 |
|--------|------|
| `<Space>gg` | **打开 LazyGit** |
| `<Space>gl` | Git 日志 |
| `<Space>gf` | 当前文件 Git 历史 |
| `<Space>gs` | 暂存当前 hunk |
| `<Space>gr` | 重置当前 hunk |
| `<Space>gS` | 暂存整个文件 |
| `<Space>gR` | 重置整个文件 |
| `<Space>gu` | 取消暂存 hunk |
| `<Space>gp` | 预览变更 hunk |
| `<Space>gb` | 查看当前行 blame |
| `<Space>gB` | 开关行 blame 显示 |
| `<Space>gd` | 文件 diff |
| `]h` / `[h` | 跳到下/上一个 hunk |
| `ih` | 选中 hunk（Visual/Operator 模式） |

---

## 🖥️ 终端

| 快捷键 | 功能 |
|--------|------|
| `<C-\>` | 切换终端（浮动） |
| `<Space>tf` | 浮动终端 |
| `<Space>th` | 水平终端 |
| `<Space>tv` | 垂直终端 |
| `Esc` 或 `jk` | 退出终端模式 |

---

## ⚡ 快速跳转（Flash）

| 快捷键 | 功能 |
|--------|------|
| `s` | 字符跳转（高亮标记） |
| `S` | Treesitter 节点跳转 |
| `f/F/t/T` | 行内增强跳转 |
| `r` (operator) | Flash 远程操作 |

---

## 📑 缓冲区管理

| 快捷键 | 功能 |
|--------|------|
| `<S-h>` | 上一个缓冲区 |
| `<S-l>` | 下一个缓冲区 |
| `<Space>bd` | 关闭当前缓冲区 |
| `<Space>bD` | 强制关闭 |
| `<Space>bo` | 关闭其他缓冲区 |
| `<Space>bp` | 标记/取消固定缓冲区 |
| `<Space>br` / `<Space>bl` | 关闭右/左侧缓冲区 |

---

## 🪟 窗口管理

| 快捷键 | 功能 |
|--------|------|
| `<C-h/j/k/l>` | 切换窗口 |
| `<Space>sv` | 垂直分割 |
| `<Space>sh` | 水平分割 |
| `<Space>se` | 均分窗口 |
| `<Space>sx` | 关闭当前窗口 |
| `<C-Up/Down/Left/Right>` | 调整窗口大小 |

---

## 🔢 代码折叠（UFO）

| 快捷键 | 功能 |
|--------|------|
| `zR` | 展开所有折叠 |
| `zM` | 折叠所有 |
| `zr` | 展开一级 |
| `zm` | 折叠一级 |
| `zp` | 预览折叠内容 |

---

## 🗂️ 会话管理

| 快捷键 | 功能 |
|--------|------|
| `<Space>qs` | 恢复上次会话 |
| `<Space>ql` | 恢复最后会话 |
| `<Space>qd` | 退出不保存会话 |

---

## 🔔 通知

| 快捷键 | 功能 |
|--------|------|
| `<Space>nh` | 通知历史 |
| `<Space>nd` | 关闭所有通知 |
| `<Space>snl` | 最后一条消息 |
| `<Space>snh` | Noice 历史 |

---

## ⚙️ 通用编辑技巧

| 快捷键 | 功能 |
|--------|------|
| `<Space>w` | 保存文件 |
| `<Space>q` | 退出 |
| `<Space>Q` | 退出全部 |
| `<Space>h` | 清除搜索高亮 |
| `<Space>r` | 替换光标下单词（全文） |
| `jk` | Insert 模式退出 |
| `<C-d/u>` | 翻页并保持光标居中 |
| `n/N` | 搜索跳转并居中 |
| `J/K` (Visual) | 上下移动选中文本 |
| `>/<` (Visual) | 缩进并保持选中 |
| `p` (Visual) | 粘贴不覆盖寄存器 |
| `]]` / `[[` | 跳到下/上一个同名引用 |
| `]w` / `[w` | 跳到下/上一个引用词 |
| `]t` / `[t` | 跳到下/上一个 TODO |

---

## 🛠️ 常用命令

```
:Lazy          插件管理（S=同步更新，U=更新全部）
:Mason         LSP/工具管理
:LspInfo       当前 LSP 状态
:ConformInfo   格式化工具状态
:checkhealth   环境健康检查
:TSInstall     安装 Treesitter 语法
:noa w         保存（跳过格式化）
```
