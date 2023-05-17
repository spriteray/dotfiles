
local develop = {}
local global = require( 'global' )

function develop.load( cppfilelist )
    return {
        -- A
        {
            'vim-scripts/a.vim', ft = cppfilelist,
            dependencies = { 'SirVer/ultisnips' },
        },

        -- todo
        {
            'folke/todo-comments.nvim',
            opts = {
                keywords = {
                    NOTICE = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
                },
            },
        },

        -- comment
        {
            'numToStr/Comment.nvim',
            opts = { },
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
            'nvim-telescope/telescope-fzf-native.nvim', build = 'make',
        },

        {
            'nvim-telescope/telescope.nvim',
            dependencies = {
                'nvim-lua/plenary.nvim',
                'BurntSushi/ripgrep',
                'nvim-telescope/telescope-ui-select.nvim',
                'nvim-telescope/telescope-fzf-native.nvim',
            },
            build = function()
                global:install( 'ripgrep' )
            end,
            init = function()
                local plugin = require( 'telescope' )
                plugin.load_extension('fzf')
                plugin.load_extension('ui-select')
                plugin.setup( {
                    defaults = {
                        mappings = {
                            i = {
                                ['<C-h>'] = 'which_key',
                            },
                            n = {
                                ['q'] = require('telescope.actions').close,
                            },
                        },
                    },
                    extensions = {
                        fzf = {
                            fuzzy = true, override_generic_sorter = true, override_file_sorter = true, case_mode = 'smart_case',
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
                local builtin = require('telescope.builtin')
                vim.keymap.set({'n','v'}, '<C-p>', builtin.find_files, {})
                vim.keymap.set({'n','v'}, '<leader>bb', builtin.buffers, {})
                vim.keymap.set({'n','v'}, '<leader>ff', function()
                    local data = global:selection()
                    if data == '' then
                        builtin.live_grep({})
                    else
                        builtin.live_grep({ default_text = data })
                    end
                end, opt )
                vim.keymap.set('n', '<leader>fs', builtin.grep_string, {})
            end,
        },

        -- terminal
        {
            'akinsho/toggleterm.nvim',
            opts = {
                open_mapping = [[<F2>]], direction = 'float',
            },
        },

        -- clang-format
        {
            'rhysd/vim-clang-format',
            config = function()
                vim.api.nvim_create_autocmd( 'FileType', {
                    pattern = { 'c','cpp','objc' },
                    callback = function()
                        vim.keymap.set( 'v', '<F3>', ':ClangFormat<cr>', { desc = 'CodeFormatV', noremap = true, buffer = true, silent = true } )
                        vim.keymap.set( 'n', '<F3>', ':<C-u>ClangFormat<cr>', { desc = 'CodeFormatN', noremap = true, buffer = true, silent = true } )
                    end,
                } )
            end
        },

        -- you complete me
        {
            dir = '/home/ryan/app/YouCompleteMe', ft = cppfilelist,
            config = function()
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
