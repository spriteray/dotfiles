
local develop = {}
local global = require( 'global' )

function develop.load( cppfilelist )
    return {
        -- A
        { 'vim-scripts/a.vim', ft = cppfilelist },

        -- todo
        {
            'folke/todo-comments.nvim',
            opts = {
                keywords = {
                    NOTICE = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
                },
            },
        },

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
            dependencies = { 
                'nvim-lua/plenary.nvim', 
                'BurntSushi/ripgrep', 
                'nvim-telescope/telescope-ui-select.nvim',
                'nvim-telescope/telescope-fzf-native.nvim', build = 'make',
            },
            build = function()
                global:install( 'ripgrep' )
            end,
            init = function()
                local builtin = require('telescope.builtin')
                vim.keymap.set({'n','i','v'}, '<C-p>', builtin.find_files, {})
                vim.keymap.set({'n','i','v'}, '<leader>bb', builtin.buffers, {})
                vim.keymap.set({'n','i','v'}, '<leader>ff', builtin.grep_string, {})
                require('telescope').load_extension('fzf')
                require('telescope').load_extension('ui-select')
            end,
            opts = function()
                require( 'telescope' ).setup( {
                    extensions = {
                        fzf = {
                            fuzzy = true, override_generic_sorter = true, override_file_sorter = true, case_mode = "smart_case",
                        },
                        ['ui-select'] = {
                            require('telescope.themes').get_dropdown({
                                previewer        = true,
                                initial_mode     = 'normal',
                                sorting_strategy = 'ascending',
                                layout_strategy  = 'horizontal',
                                layout_config    = {
                                    horizontal = { width = 0.5, height = 0.4, preview_width = 0.6 },
                                },
                            })
                        };
                    },
                })
            end,
        },

        -- terminal
        {
            'akinsho/toggleterm.nvim',
            opts = {
                open_mapping = [[<F4>]],
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

        -- you complete me
        {
            dir = '/home/ryan/app/YouCompleteMe', ft = cppfilelist,
            config = function()
                vim.opt.completeopt = { 'menuone', 'menu', 'longest' }
                vim.g.ycm_error_symbol = 'X'
                vim.g.ycm_warning_symbol = '?'
                vim.g.ycm_confirm_extra_conf = 0
                vim.g.ycm_show_diagnostics_ui = 1
                vim.g.ycm_min_num_identifier_candidate_chars = 2
                vim.g.ycm_collect_identifiers_from_comments_and_strings = 1
                vim.g.ycm_seed_identifiers_with_syntax = 1
                vim.g.ycm_min_num_of_chars_for_completion = 1
                vim.g.ycm_key_invoke_completion = '<c-z>'
                vim.g.ycm_filetype_blacklist = "'tagbar' : 1,\
                    'qf' : 1, 'notes' : 1, 'markdown' : 1, 'unite' : 1, \
                    'text' : 1, 'vimwiki' : 1, 'pandoc' : 1, 'infolog' : 1, 'gitcommit' : 1, 'mail' : 1"
            end,
            keys = {
                { '<F11>', ':YcmCompleter GoTo<cr>', mode = 'n', desc = 'YouCompleteMeGoto1', noremap = true, silent = true },
                { '<F12>', ':YcmCompleter GoToDeclaration<cr>', mode = 'n', desc = 'YouCompleteMeGoto2', noremap = true, silent = true },
            },
        },
    }
end

return develop
