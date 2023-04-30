
require('options')

local lazypath = pluginpath .. '/lazy.nvim'

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

require('lazy').setup( {
    -- colorscheme
    'tanvirtin/monokai.nvim',

    -- cpp
    -- 1. a
    { 'vim-scripts/a.vim', ft = cppfilelist },
    -- 2. cpp highlight
    {
        'octol/vim-cpp-enhanced-highlight', ft = cppfilelist,
        init = function()
            vim.g.cpp_class_scope_highlight = 1
            vim.g.cpp_member_variable_highlight = 1
            vim.g.cpp_class_decl_highlight = 1
            vim.g.cpp_experimental_simple_template_highlight = 1
            vim.g.cpp_concepts_highlight = 1
            vim.g.cpp_posix_standard = 1
        end,
    },

    -- statusline
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons', opt=true },
        opts = {
            options = {
                icons_enabled = true,
                theme = 'molokai',
                component_separators = { left = '', right = ''},
                section_separators = { left = '', right = ''},
                disabled_filetypes = { statusline = {}, winbar = {} },
                ignore_focus = {},
                always_divide_middle = true,
                globalstatus = false,
                refresh = { statusline = 1000, tabline = 1000, winbar = 1000, },
            },
            sections = {
                lualine_a = {'mode'},
                lualine_b = {'branch', 'diff', 'diagnostics'},
                lualine_c = {'filename'},
                lualine_x = {'encoding', 'fileformat', 'filetype'},
                lualine_y = {'progress'},
                lualine_z = {'location'}
            },
        },
    },

}, {
    root = pluginpath,
    state = pluginpath .. '/state.json',
    lockfile = vim.fn.stdpath( 'data' ) .. '/lazy-lock.json',
} )
