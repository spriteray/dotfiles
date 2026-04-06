local global = require('global')
local scheme = require('colorscheme')

-- ── 个人配置 ──────────────────────────────────────────────────────────────
local profile = {
    status_line_scheme = 'solarized_light',
    -- status_line_scheme = 'nightfox',
    -- status_line_scheme = 'ayu',
    color_scheme = {
        scheme = 'solarized', background = 'light',
        -- scheme = 'nightfox', background = 'dark',
        -- scheme = 'tokyonight', background = 'light',
        -- scheme = 'ayu', background = 'light',
    },
}

-- ── 文件类型 ───────────────────────────────────────────────────────────────
local cppfilelist    = { 'cpp', 'c', 'h', 'cc', 'hpp', 'objc' }
local scriptfilelist = { 'py', 'lua' }

-- ── 插件根目录 ─────────────────────────────────────────────────────────────
local pluginpath = vim.fn.stdpath('data') .. '/plugin'

-- ── 启动顺序 ───────────────────────────────────────────────────────────────
global:init()                               		-- 1. 全局平台信息
require('basic')                                    -- 2. 基础 vim 选项
global:diagnostic()                                 -- 3. 诊断 UI 配置

local plugins = require('plugins')
plugins.init( pluginpath )                          -- 4. 初始化 lazy.nvim
plugins.load( pluginpath, 
		cppfilelist, scriptfilelist,
        profile.status_line_scheme )                -- 5. 加载所有插件

global:register( cppfilelist, scriptfilelist )      -- 6. 快捷键 & autocmd
scheme.apply_scheme( profile.color_scheme )         -- 7. 应用配色