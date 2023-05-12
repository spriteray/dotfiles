
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

function global:selection()
    vim.cmd('noau normal! "vy"')
    local text = vim.fn.getreg("v")
    vim.fn.setreg("v", {})

    text = string.gsub(text, "\n", "")
    if #text > 0 then
        return text
    else
        return ""
    end
end

function global:register()
    local wk = require( 'which-key' )
    wk.register({
        ['<leader>c'] = { '<cmd>nohls<cr>', 'Clear HighLight' },
        ['<leader>co'] = { '<cmd>:copen<cr>', 'Open qf Window' },
        ['<leader>cc'] = { '<cmd>:cclose<cr>', 'Close qf Window' },
        ['<leader>fd'] = { '<cmd>:set ff=dos<cr>', 'Set File-Format DOS' },
        ['<leader>fu'] = { '<cmd>:set ff=unix<cr>', 'Set File-Format UNIX' },
        ['<leader>fm'] = { '<cmd>:set ff=mac<cr>', 'Set File-Format MAC' },
    })
end

return global
