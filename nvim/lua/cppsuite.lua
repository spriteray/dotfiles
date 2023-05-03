
local cppsuite = {}

function cppsuite.load( cppfilelist )
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
            dependencies = { 'nvim-lua/plenary.nvim' },
        },
    }
end

return cppsuite
