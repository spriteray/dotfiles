
local global = {}

function global:init()
    self.os_name = vim.loop.os_uname().sysname
    self.is_mac = self.os_name == 'Darwin'
    self.is_linux = self.os_name == 'Linux'
    self.is_windows = self.os_name == 'Windows_NT'
    self.is_wsl = vim.fn.has( 'wsl' ) == 1
end

function global:install( app )
    if self.is_mac then
        vim.fn.system( { 'brew', 'install', app } )
    elseif self.is_linux then
        vim.fn.system( { 'apt', 'install', app } )
    elseif self.is_wsl then
        vim.fn.system( { 'apt', 'install', app } )
    else
        vim.notify( 'install ' .. app .. ' failed!' )
    end
end

return global
