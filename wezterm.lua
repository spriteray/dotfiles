local wezterm = require 'wezterm'

local config = wezterm.config_builder()

local launch_menu = {}
local default_prog = {}
local wsl2_options = { 'wsl', '-u', 'ryan', '--cd', '~' }

-- local config = wezterm.config_builder()
local wsl_domains = wezterm.default_wsl_domains()
local is_windows = wezterm.target_triple == 'x86_64-pc-windows-msvc'
local is_mac = wezterm.target_triple:find("apple-darwin") ~= nil

--
-- 字体选择
--
--local font_options = { family = 'Comic Mono', weight = 'Regular', size = 14.7, width = 0.9, height = 1.0 }
--local font_options = { family = 'PragmataPro', weight = 'Regular', size = 16, width = 0.88, height = 1.0 }
--local font_options = { family = 'Lilex Medium', weight = 'Regular', size = 14.5, width = 0.88, height = 1.0 }
--local font_options = { family = 'NanumGothicCoding', weight = 'Regular', size = 16, width = 0.88, height = 1.0 }
--local font_options = { family = 'Droid Sans Mono', weight = 'Regular', size = 14.5, width = 0.9, height = 1.0 }
--local font_options = { family = 'Cascadia Code SemiLight', weight = 'Regular', size = 14.7, width = 0.9, height = 1.0 }
--local font_options = { family = 'Hasklig Medium', weight = 'Regular', size = 15, width = 0.83, height = 1.0 }
--local font_options = { family = 'Conta Mono', weight = 'Regular', size = 14.5, width = 0.9, height = 1.0 }
--local font_options = { family = 'Operator Mono SSm Light', weight = 'Regular', size = 14.5, width = 0.9, height = 1.0 }
--local font_options = { family = 'Rec Mono Casual', weight = 'Regular', size = 14.5, width = 0.8, height = 1.0 }
local font_options = { family = 'Recursive Monospace Casual', weight = 'Regular', size = 14.3, width = 0.85, height = 1.0 }
--local font_options = { family = 'Monaspace Argon NF Light', weight = 'Regular', size = 14.5, width = 0.85, height = 1.0 }

-- 
-- 系统相关
-- 
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
    --
    -- windows
    --
    term = '' -- Set to empty so FZF works on windows
    table.insert( launch_menu, {
        label = 'LOCAL:CMD',
        args = {'cmd.exe', '-NoLogo'}
    } )
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
    default_prog = {'powershell.exe', '-NoLogo'}
else 
    --
    -- macos
    --
    table.insert( launch_menu, {
        label = 'LOCAL:Zsh',
        args = {'zsh'}
    } )
    table.insert( launch_menu, {
        label = 'REMOTE:tssh(s)',
        args = { 'tssh' }
    } )
    default_prog = {'zsh'}
    font_options = { family = 'Recursive Monospace Casual', weight = 'Regular', size = 16, width = 0.88, height = 1.0 }
end

--
-- 快捷键
--
local keys = {
    { key = 'L', mods = 'CTRL', action = wezterm.action.ShowDebugOverlay },
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
    },
    {
        event = { Up = { streak = 1, button = 'Right' } },
        mods = is_mac and 'CMD' or 'ALT', -- 加个修饰键，防止误删
        action = wezterm.action.CloseCurrentTab { confirm = true },
    },
}

-- wezterm.on('gui-startup', function(cmd)
--     local tab, pane, window = mux.spawn_window(cmd or {})
--     window:gui_window():perform_action( wezterm.action.ShowLauncher, pane )
-- end)

-- 环境变量
local function get_env()
    local extra_paths = {}
    local path_sep = is_windows and ";" or ":"
    if is_windows then
        table.insert(extra_paths, "D:\\Applications\\nvim\\bin")
        -- 你可以继续添加 Windows 特有路径
    else
        -- 针对 macOS (M1/M2/M3 芯片路径)
        table.insert(extra_paths, "/opt/homebrew/bin")
        table.insert(extra_paths, "/usr/local/bin")
    end
    local joined_paths = table.concat(extra_paths, path_sep)
    return {
        -- 将新路径放在最前面，确保 Python 3.12 等工具优先被命中
        PATH = joined_paths .. path_sep .. os.getenv("PATH"),
        -- 你也可以在这里统一管理其他变量
        MY_PROJECT_ROOT = is_windows and "D:\\Codes" or "/Users/ryan/Codes",
    }
end

local options =  {
	launch_menu = launch_menu,
    default_prog = default_prog,
    keys = keys,
    mouse_bindings = bingings,

    -- window
    -- window_background_opacity = 0.95,
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
        --freetype_load_flags = 'NO_AUTOHINT|MONOCHROME',
        freetype_load_flags = 'FORCE_AUTOHINT',
        --freetype_load_target = 'VerticalLcd', freetype_render_target = 'Light',
        freetype_load_target = 'HorizontalLcd', freetype_render_target = 'Light',
    }, 
    font_size = font_options.size, 
    cell_width = font_options.width, line_height = font_options.height,
  	
    color_scheme = "Solarized (light) (terminal.sexy)",
  	--color_scheme = "Ayu Light (Gogh)",
    --color_scheme = "nightfox",
      	
    -- tab bar
    enable_tab_bar = true,
    use_fancy_tab_bar = false,
    show_new_tab_button_in_tab_bar = true,
  	hide_tab_bar_if_only_one_tab = true,
    --tab_bar_at_bottom=true,
    tab_max_width=40,
    switch_to_last_active_tab_when_closing_tab = true,
    set_environment_variables = get_env(),

    window_decorations = "INTEGRATED_BUTTONS|RESIZE",
    integrated_title_button_style = is_windows and "Windows" or "MacNative",
}

-- 循环注入
for k,v in pairs(options) do
    config[k] = v
end

return config
