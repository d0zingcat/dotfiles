local wezterm = require('wezterm')
local act = wezterm.action
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
    use_fancy_tab_bar = true,
    -- hide_tab_bar_if_only_one_tab = true,
    color_scheme = 'tokyonight',
    window_decorations = "INTEGRATED_BUTTONS | RESIZE",
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
    ssh_domains = {
        {
            name = 'debian',
            remote_address = 'debian01',
            username = 'd0zingcat',
            multiplexing = 'None',
        },
    },
    keys = {
        --{ key = 'l', mods = 'CMD', action = wezterm.action({ ShowLauncherArgs = { flags = 'FUZZY|DOMAINS' } }) },
        --{ key = 's', mods = 'CMD', action = wezterm.action({ ShowLauncherArgs = { flags = 'FUZZY|WORKSPACES' } }) },
        { key = 'e', mods = 'CMD', action = wezterm.action({ EmitEvent = 'window-visible-text' }) },
        { key = 'l', mods = 'CMD', action = wezterm.action({ ShowLauncherArgs = { flags = 'DOMAINS' } }) },
        { key = 'w', mods = 'CMD', action = wezterm.action({ CloseCurrentPane = { confirm = false } }) },
        { key = 'd', mods = 'CMD', action = wezterm.action({ SplitHorizontal = { domain = 'CurrentPaneDomain' } }) },
        {
            key = 'd',
            mods = 'CMD|SHIFT',
            action = wezterm.action({ SplitVertical = { domain = 'CurrentPaneDomain' } }),
        },
        {
            key = '[',
            mods = 'CMD',
            action = wezterm.action({ ActivatePaneDirection = 'Next' }),
        },
        {
            key = ']',
            mods = 'CMD',
            action = wezterm.action({ ActivatePaneDirection = 'Prev' }),
        },
        {
            key = '>',
            mods = 'CMD|SHIFT',
            action = wezterm.action.MoveTabRelative(1),
        },
        {
            key = '<',
            mods = 'CMD|SHIFT',
            action = wezterm.action.MoveTabRelative(-1),
        },
        { key = 'Enter', mods = 'CMD', action = 'ToggleFullScreen' },
    },
    -- hyperlink_rules = {
    --     {
    --         regex = [[\b(https|http)://\S*\b]],
    --         format = '$0',
    --     },
    --     {
    --         regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
    --         format = 'https://www.github.com/$1/$3',
    --     }
    -- }
}
