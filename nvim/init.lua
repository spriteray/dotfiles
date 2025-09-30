
local global = require( 'global' )
local scheme = require( 'colorscheme' )

-- 个性设置
local profile = {
	--status_line_scheme = 'solarized_light',
	-- status_line_scheme = 'nightfox',
	status_line_scheme = 'ayu',
	color_scheme = {
		-- scheme = 'solarized', background = 'light',
		-- scheme = 'nightfox', background = 'dark',
		-- scheme = 'tokyonight', background = 'light',
		scheme = 'ayu', background = 'light',
	},
}

-- cpp文件类型列表
local cppfilelist = { 'cpp', 'c', 'h', 'cc', 'hpp', 'objc' }
local scriptfilelist = { 'py', 'lua' }
-- 插件根目录
local pluginpath = vim.fn.stdpath( 'data' ) .. '/plugin'

-- 全局参数加载
global:init()

-- 加载基础配置
require('basic')

-- 加载插件
local plugins = require('plugins')
plugins.init( pluginpath )
plugins.load( pluginpath, cppfilelist, scriptfilelist, profile.status_line_scheme )

-- 注册快捷键以及自动命令
global:register( cppfilelist, scriptfilelist )

-- 应用配色
scheme.apply_scheme( profile.color_scheme )
