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
  selection_word_boundary = " \t\n{}[]()\"'`=,.",
  -- This WezTerm release has no copy_on_select config field.
  -- 100k lines avoids the large memory cost of Ghostty's 25m-line history.
  scrollback_lines = 100000,
  window_close_confirmation = "NeverPrompt",

  use_fancy_tab_bar = true,
  hide_tab_bar_if_only_one_tab = false,
  window_frame = { font_size = 13.0 },

  -- Reach these with Cmd+L. Keeping tmux out of default_prog prevents its
  -- panes from competing with WezTerm's own splits.
  launch_menu = {
    { label = "Workspace", cwd = wezterm.home_dir .. "/Workspace", args = { "zsh", "-l" } },
  },

  keys = {
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
