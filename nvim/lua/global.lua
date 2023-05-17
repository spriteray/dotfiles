
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
    vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        callback = function()
            vim.api.nvim_exec( [[
                function! NoWhitespace()
                    let l:save = winsaveview()
                    keeppatterns %s/\s\+$//e
                    call winrestview(l:save)
                endfunction
                call NoWhitespace()
            ]], true )
        end,
    })
    vim.cmd([[
        hi WhitespaceEOF ctermbg=grey guibg=grey
        match WhitespaceEOF /\s\+$/
    ]])
    vim.keymap.set( 'n', '<leader>c',  '<cmd>nohls<cr>', { desc = 'Clear HighLight' } )
    vim.keymap.set( 'n', '<leader>co', '<cmd>:copen<cr>', { desc = 'Open qf Window' } )
    vim.keymap.set( 'n', '<leader>cc', '<cmd>:cclose<cr>', { desc = 'Close qf Window' } )
    vim.keymap.set( 'n', '<leader>fd', '<cmd>:set ff=dos<cr>',{ desc = 'Set File-Format DOS' } )
    vim.keymap.set( 'n', '<leader>fu', '<cmd>:set ff=unix<cr>', { desc = 'Set File-Format UNIX' } )
    vim.keymap.set( 'n', '<leader>fm', '<cmd>:set ff=mac<cr>', { desc = 'Set File-Format MAC' } )
end

return global
