
local plugins = {}

function plugins.init( rootpath )
    local lazypath = rootpath .. '/lazy.nvim'
    if not vim.loop.fs_stat( lazypath ) then
        vim.fn.system( {
            'git',
            'clone',
            '--filter=blob:none',
            'https://github.com/folke/lazy.nvim.git',
            '--branch=stable',
            lazypath,
        } )
    end
    vim.opt.rtp:prepend( lazypath )
end

function plugins.load( rootpath, cppfilelist )
    require('lazy').setup( {
        -- vimgui
        require( 'vimgui' ).load( cppfilelist ),
        -- cpp suite
        require( 'cppsuite' ).load( cppfilelist ),
    }, {
        root = rootpath,
        state = rootpath .. '/state.json',
        lockfile = vim.fn.stdpath( 'data' ) .. '/lazy-lock.json',
    } )
end

return plugins
