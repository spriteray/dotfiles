
local develop = {}

function develop.load( cppfilelist )
    return {
        -- A
        { 'vim-scripts/a.vim', ft = cppfilelist },

        -- highlight
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

        -- telescope
        {
            'nvim-telescope/telescope.nvim',
            dependencies = { 'nvim-lua/plenary.nvim', 'BurntSushi/ripgrep' },
            init = function()
                local builtin = require('telescope.builtin')
                vim.keymap.set({'n','i','v'}, '<C-p>', builtin.find_files, {})
                vim.keymap.set({'n','i','v'}, '<leader>bb', builtin.buffers, {})
                vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
            end,
        },

        -- terminal
        {
            'akinsho/toggleterm.nvim',
            opts = {
                open_mapping = [[<C-`>]],
                direction = 'float',
            },
        },

        -- clang-format
        {
            'rhysd/vim-clang-format', ft = cppfilelist,
            keys = {
                { '<F3>', ':ClangFormat<cr>', mode = 'v', desc = 'CodeFormatV', noremap = true, buffer = true, silent = true },
                { '<F3>', ':<C-u>ClangFormat<cr>', mode = 'n', desc = 'CodeFormatN', noremap = true, buffer = true, silent = true },
            },
        },
    }
end

return develop
