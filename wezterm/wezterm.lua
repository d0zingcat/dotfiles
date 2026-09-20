-- WezTerm configuration for macOS.
-- It intentionally stays compatible with the latest stable release
-- (20240203-110809-5046fc22).
local wezterm = require("wezterm")
local act = wezterm.action

local config = {
  font_dirs = { wezterm.home_dir .. "/Library/Fonts" },
  -- Use fonts that this WezTerm build can enumerate. macOS's automatic
  -- fallback selected Apple SD Gothic Neo for some Han characters and missed
  -- others in the previous configuration.
  font = wezterm.font_with_fallback({
    "JetBrains Maple Mono",
  }),
  font_size = 13,
  line_height = 1.15,

  -- Matches the Ghostty theme. Other useful built-ins: "Tokyo Night",
  -- "Kanagawa Dragon", and "Everforest Dark Hard".
  color_scheme = "Catppuccin Mocha",
  window_background_opacity = 0.90,
  macos_window_background_blur = 20,
  window_decorations = "INTEGRATED_BUTTONS | RESIZE",
  window_padding = { left = 8, right = 8, top = 8, bottom = 8 },

  default_cwd = wezterm.home_dir,
  use_ime = true,
  default_cursor_style = "BlinkingBar",
  cursor_blink_rate = 500,
  -- 双击取词：`.` 不做分词，`cleanup-cache.log` / `app.tar.gz` / 域名 IP 才能一次选中；
  -- 代价是句尾 `foo.` 会连点一起选中，可接受。
  selection_word_boundary = " \t\n{}[]()\"'`=,、，。；：？！（）【】《》“”‘’",
  -- Hyperlink: 修复 `(https://.../47)` 被连同 trailing `)` 一起识别的 bug
  -- (20240203 默认规则 `\\b\\w+://\\S+[)/a-zA-Z0-9-]+` 会把 `)` 吞进 URL，
  -- 点开就是 `.../47)` -> Gitea 404，看起来像“点不动”)。
  -- 裸 URL 规则末尾排除 `) ] } > . , ; : ' " !`，括号包裹的规则用非贪婪 `+?` 只取本体。
  -- 2026-09-20: 中文标点 `（未合并）。` 也会被 `\\S+` 吞进 URL
  -- (比如 `https://.../pulls/48（未合并）。` 点开变成 `.../48%EF%BC%88...` -> 404)，
  -- 所以 URL 本体改用 `[^\\s()\\[\\]{}<>\"'...全角标点]`，遇到全角标点即停。
  hyperlink_rules = {
    { regex = "\\((\\w+://[^\\s\\)\\(\"'>、。﹐，；：？！（）【】《》“”‘’…—·　]+)\\)", format = "$1", highlight = 1 },
    { regex = "\\[(\\w+://[^\\s\\]\\(\"'>、。﹐，；：？！（）【】《》“”‘’…—·　]+)\\]", format = "$1", highlight = 1 },
    { regex = "\\{(\\w+://[^\\s\\}\\(\"'>、。﹐，；：？！（）【】《》“”‘’…—·　]+)\\}", format = "$1", highlight = 1 },
    { regex = "<(\\w+://[^\\s<>(\\\"'、。﹐，；：？！（）【】《》“”‘’…—·　]+)>", format = "$1", highlight = 1 },
    { regex = "\\b\\w+://[^\\s()\\[\\]{}<>\"'、。﹐，；：？！（）【】《》“”‘’…—·　]+[^\\s)\\]\\}>.,;:'\"!。、﹐，；：？！（）【】《》“”‘’…—·　]", format = "$0" },
    { regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b", format = "mailto:$0" },
  },
  -- tmux 开了 `mouse on` 时，普通单击会被 tmux 吃掉选 pane，wezterm 看不到链接。
  -- 设成 SHIFT|CMD 穿透：Shift+点(默认) 和 Cmd+点(macOS 习惯) 都能直达 wezterm。
  -- 注意：20240203 的 bypass_mouse_reporting_modifiers 只认单个值，
  -- "SHIFT|CMD" / "SHIFT|SUPER" 实测都会让穿透整个失效(Shift/Cmd 全灭)。
  -- 所以这里只能写 SHIFT；Cmd+点在非 tmux 下照常用(tmux 里改用 Shift+点，
  -- SGR 鼠标协议本身就没有 Super 位，tmux 侧也接不到 Cmd，无解)。
  bypass_mouse_reporting_modifiers = "SHIFT",
  mouse_bindings = {
    -- tmux 里 Shift+点穿透进来后按 NONE 匹配，走默认也能开；
    -- 但显式绑一份 SHIFT 更稳：即使默认行为变化也不受影响
    { event = { Up = { streak = 1, button = "Left" } }, mods = "SHIFT", action = act.OpenLinkAtMouseCursor },
    { event = { Down = { streak = 1, button = "Left" } }, mods = "SHIFT", action = act.Nop },
    -- macOS 习惯：Cmd+左键打开光标下链接；Down 配 Nop 避免误给 tmux 发奇怪序列
    { event = { Up = { streak = 1, button = "Left" } }, mods = "CMD", action = act.OpenLinkAtMouseCursor },
    { event = { Down = { streak = 1, button = "Left" } }, mods = "CMD", action = act.Nop },
    -- 非 tmux 下保持默认行为：普通单击也能开链接(CompleteSelectionOrOpenLinkAtMouseCursor)，这里不覆盖 NONE
  },
  -- This WezTerm release has no copy_on_select config field.
  -- 100k lines avoids the large memory cost of Ghostty's 25m-line history.
  scrollback_lines = 100000,
  window_close_confirmation = "AlwaysPrompt",

  use_fancy_tab_bar = true,
  hide_tab_bar_if_only_one_tab = false,
  window_frame = { font_size = 13.0 },

  -- Reach these with Cmd+L. Keeping tmux out of default_prog prevents its
  -- panes from competing with WezTerm's own splits.
  launch_menu = {
    { label = "Workspace", cwd = wezterm.home_dir .. "/Workspace", args = { "zsh", "-l" } },
  },

  keys = {
    { key = "q", mods = "CMD", action = act.QuitApplication },
    { key = "l", mods = "CMD", action = act.ShowLauncherArgs({ flags = "FUZZY|LAUNCH_MENU_ITEMS|DOMAINS" }) },
    { key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = false }) },
    { key = "d", mods = "CMD", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "d", mods = "CMD|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "[", mods = "CMD", action = act.ActivatePaneDirection("Next") },
    { key = "]", mods = "CMD", action = act.ActivatePaneDirection("Prev") },
    { key = "h", mods = "CMD|ALT", action = act.ActivateTabRelative(-1) },
    { key = "l", mods = "CMD|ALT", action = act.ActivateTabRelative(1) },
    { key = "h", mods = "ALT", action = act.MoveTabRelative(-1) },
    { key = "l", mods = "ALT", action = act.MoveTabRelative(1) },
    { key = "h", mods = "CMD|SHIFT", action = act.ActivatePaneDirection("Left") },
    { key = "j", mods = "CMD|SHIFT", action = act.ActivatePaneDirection("Down") },
    { key = "k", mods = "CMD|SHIFT", action = act.ActivatePaneDirection("Up") },
    { key = "l", mods = "CMD|SHIFT", action = act.ActivatePaneDirection("Right") },
    { key = "f", mods = "CMD|SHIFT", action = act.TogglePaneZoomState },
    { key = ",", mods = "CMD|SHIFT", action = act.ReloadConfiguration },
    { key = "Enter", mods = "CMD", action = act.ToggleFullScreen },
  },
}

return config
