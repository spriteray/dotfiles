
local global = require( 'global' )
local scheme = require( 'colorscheme' )

-- cpp文件类型列表
local cppfilelist = { 'cpp', 'c', 'h', 'cc', 'hpp' }
-- 插件根目录
local pluginpath = vim.fn.stdpath( 'data' ) .. '/plugin'

-- 全局参数加载
global:init()

-- 加载基础配置
require('basic')

-- 加载插件
local plugins = require('plugins')
plugins.init( pluginpath )
plugins.load( pluginpath, cppfilelist )

-- 注册快捷键
global:register()

-- 应用配色
if global.is_mac then
    scheme.apply( 'solarized', 'light' )
else
    scheme.apply( 'nightfox', 'dark' )
end
