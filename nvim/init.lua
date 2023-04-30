
local colorscheme = 'monokai_pro'
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

-- 应用配色
local is_ok,_ = pcall( vim.cmd, "colorscheme "..colorscheme )
if not is_ok then
    vim.notify( 'colorscheme ' .. colorscheme .. ' not found !' )
end
