
-- cpp文件类型列表
cppfilelist = { 'cpp', 'c', 'h', 'cc', 'hpp' }
-- 插件根目录
pluginpath = vim.fn.stdpath( 'data' ) .. '/plugin'

-- 加载配置
local plugins = require('plugins')
plugins.init( pluginpath )
plugins.load( pluginpath, cppfilelist )

-- 加载其他选项
require('basic')
require('colorscheme')
