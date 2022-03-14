local wezterm = require('wezterm')
return {
    default_cwd = wezterm.home_dir .. '/work',
    font_size = 14,
    font = wezterm.font_with_fallback({
        'JetBrains Mono',
        'JetBrainsMono Nerd Font Mono',
    }),
    colors = {
        tab_bar = {
            active_tab = {
                bg_color = '#24283b',
                fg_color = '#c0caf5',
            },
        },
    },
    color_scheme = 'tokyonight',
    window_frame = {
        font_size = 14.0,
    },
    window_padding = {
        left = 5,
        right = 5,
        top = 0,
        bottom = 0,
    },
    foreground_text_hsb = {
        hue = 1.0,
        saturation = 1.0,
        brightness = 1.2,
    },
    use_ime = true, -- fix Chinese
    skip_close_confirmation_for_processes_named = {
        'fzf',
        'zsh',
        'fzf',
    },
    keys = {
        { key = 'w', mods = 'CMD', action = wezterm.action({ CloseCurrentTab = { confirm = false } }) },
    },
}
