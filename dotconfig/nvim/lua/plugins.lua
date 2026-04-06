local plugins = {}

-- ── 初始化 lazy.nvim ───────────────────────────────────────────────────────
function plugins.init(rootpath)
    local lazypath = rootpath .. '/lazy.nvim'
    if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
            'git', 'clone', '--filter=blob:none',
            'https://github.com/folke/lazy.nvim.git',
            '--branch=stable', lazypath,
        })
    end
    vim.opt.rtp:prepend(lazypath)
end

-- ── 加载所有插件 ───────────────────────────────────────────────────────────
function plugins.load(rootpath, cppfilelist, scriptfilelist, scheme)
    require('lazy').setup({
        require('colorscheme').load(),
        require('vimgui').load(cppfilelist, scriptfilelist, scheme),
        require('develop').load(cppfilelist),
    }, {
        root     = rootpath,
        state    = rootpath .. '/state.json',
        lockfile = vim.fn.stdpath('data') .. '/lazy-lock.json',
    })
end

return plugins
