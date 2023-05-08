
-- cpp文件类型列表
local cppfilelist = { 'cpp', 'c', 'h', 'cc', 'hpp' }
-- 插件根目录
local pluginpath = vim.fn.stdpath( 'data' ) .. '/plugin'

-- 加载基础配置
require('basic')

-- 加载插件
local plugins = require('plugins')
plugins.init( pluginpath )
plugins.load( pluginpath, cppfilelist )

-- 系统配置
-- local is_mac = vim.fn.has( 'macunix' )
-- local is_win = vim.fn.has( 'win32' )
-- local is_wsl = vim.fn.has( 'wsl' )

-- 应用配色
require( 'colorscheme' ).apply( 'molokai', 'dark' )
