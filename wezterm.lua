local wezterm = require 'wezterm'

local launch_menu = {}
local default_prog = {}
local wsl2_options = { 'wsl', '-u', 'ryan', '--cd', '~' }

-- local config = wezterm.config_builder()
local wsl_domains = wezterm.default_wsl_domains()

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
    -- windows下启用powershell
    term = '' -- Set to empty so FZF works on windows
    table.insert( launch_menu, {
        label = 'LOCAL:PowerShell',
        args = {'powershell.exe', '-NoLogo'}
    } )
    table.insert( launch_menu, {
        label = 'REMOTE:tssh(s)',
        args = { 'tssh' }
    } )
    for idx, dom in ipairs( wsl_domains ) do
        table.insert( launch_menu, {
            label = dom.name,
            args = wsl2_options
        } )
    end
    --default_prog = { 'wsl', '-u', 'ryan', '--cd', '~' }
    default_prog = {'powershell.exe', '-NoLogo'}
elseif wezterm.target_triple == 'x86_64-apple-darwin' or wezterm.target_triple == 'aarch64-apple-darwin' then
    table.insert( launch_menu, {
        label = 'LOCAL:Zsh',
        args = {'zsh'}
    } )
    table.insert( launch_menu, {
        label = 'REMOTE:tssh(s)',
        args = { 'tssh' }
    } )
    default_prog = {'/bin/zsh', '-l'}
end

--
-- 字体选择
--
--local font_options = { family = 'Comic Mono', weight = 'Regular', size = 14.5, width = 0.9, height = 1.0 }
--local font_options = { family = 'PragmataPro', weight = 'Regular', size = 16, width = 0.88, height = 1.0 }
--local font_options = { family = 'Lilex Medium', weight = 'Regular', size = 14.5, width = 0.88, height = 1.0 }
--local font_options = { family = 'NanumGothicCoding', weight = 'Regular', size = 16, width = 0.88, height = 1.0 }
--local font_options = { family = 'Droid Sans Mono', weight = 'Regular', size = 14.5, width = 0.9, height = 1.0 }
--local font_options = { family = 'Cascadia Code SemiLight', weight = 'Regular', size = 14.7, width = 0.88, height = 1.0 }
--local font_options = { family = 'Hasklig Medium', weight = 'Regular', size = 15, width = 0.83, height = 1.0 }
--local font_options = { family = 'Conta Mono', weight = 'Regular', size = 14.5, width = 0.9, height = 1.0 }
--local font_options = { family = 'Operator Mono SSm Light', weight = 'Regular', size = 14.5, width = 0.9, height = 1.0 }
local font_options = { family = 'Recursive Monospace Casual', weight = 'Regular', size = 18, width = 0.88, height = 1.0 }

--
-- 快捷键
--
local keys = {
    { key = '`', mods = 'CTRL', action = wezterm.action.SpawnCommandInNewWindow { args = wsl2_options } },
    { key = 'b', mods = 'ALT', action = wezterm.action.ShowLauncherArgs { flags = 'LAUNCH_MENU_ITEMS' }, },
}

--
-- 鼠标绑定
--
local bingings = {
    -- Paste on right-click
    {
        event = { Down = { streak = 1, button = 'Right' } },
        mods = 'NONE',
        action = wezterm.action { PasteFrom = 'Clipboard' }
    }, -- Change the default click behavior so that it only selects
    -- text and doesn't open hyperlinks
    {
        event = { Up = { streak = 1, button = 'Left' } },
        mods = 'NONE',
        action = wezterm.action { CompleteSelection = 'PrimarySelection' }
    }, -- CTRL-Click open hyperlinks
    {
        event = { Up = { streak = 1, button = 'Left' } },
        mods = 'CTRL',
        action = 'OpenLinkAtMouseCursor'
    }
}

-- wezterm.on('gui-startup', function(cmd)
--     local tab, pane, window = mux.spawn_window(cmd or {})
--     window:gui_window():perform_action( wezterm.action.ShowLauncher, pane )
-- end)

return {
	launch_menu = launch_menu,
    default_prog = default_prog,
    keys = keys,
    mouse_bindings = bingings,

    -- window
    -- window_background_opacity = 0.95,
	-- font_antialias="Subpixel",
    initial_cols = 120, initial_rows = 30,

    -- cursor
    animation_fps = 120,
    cursor_blink_ease_in = 'EaseOut',
    cursor_blink_ease_out = 'EaseOut',
    default_cursor_style = 'BlinkingBlock',
    cursor_blink_rate = 650,

    -- font设置
    font = wezterm.font {
        family = font_options.family,
        weight = font_options.weight,
        harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },
        freetype_load_flags = 'NO_AUTOHINT|MONOCHROME',
        --freetype_load_flags = 'FORCE_AUTOHINT',
        --freetype_load_target = 'Mono', freetype_render_target = 'Light',
    },
    font_size = font_options.size,
    cell_width = font_options.width, line_height = font_options.height,

    color_scheme = "Solarized (light) (terminal.sexy)",
	--color_scheme = "Ayu Light (Gogh)",

    -- tab bar
    enable_tab_bar = true,
    use_fancy_tab_bar = false,
  	hide_tab_bar_if_only_one_tab = true,
    --tab_bar_at_bottom=true,
    tab_max_width=64,
    switch_to_last_active_tab_when_closing_tab = true,
	window_decorations = "INTEGRATED_BUTTONS|RESIZE",
}
