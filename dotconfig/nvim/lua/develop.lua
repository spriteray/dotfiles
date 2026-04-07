local develop = {}
local global   = require('global')

function develop.load(cppfilelist)
    return {

        -- ── todo-comments ──────────────────────────────────────────────────
        {
            'folke/todo-comments.nvim',
            opts = {
                keywords = {
                    NOTICE = { icon = ' ', color = 'warning', alt = { 'WARNING', 'XXX' } },
                },
            },
        },

        -- ── 注释 ───────────────────────────────────────────────────────────
        {
            'numToStr/Comment.nvim', opts = {},
        },

        -- ── C++ 增强高亮 ───────────────────────────────────────────────────
        {
            'octol/vim-cpp-enhanced-highlight', ft = cppfilelist,
            init = function()
                vim.g.cpp_class_scope_highlight              = 1
                vim.g.cpp_member_variable_highlight          = 1
                vim.g.cpp_class_decl_highlight               = 1
                vim.g.cpp_experimental_simple_template_highlight = 1
                vim.g.cpp_concepts_highlight                 = 1
                vim.g.cpp_posix_standard                     = 1
            end,
        },

        -- ── telescope ──────────────────────────────────────────────────────
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
            build = function() global:install('ripgrep') end,
            config = function()
                local telescope = require('telescope')
                telescope.setup({
                    defaults = {
                        mappings = {
                            i = { ['<C-h>'] = 'which_key' },
                            n = { ['q'] = require('telescope.actions').close },
                        },
                    },
                    extensions = {
                        fzf = {
                            fuzzy                   = true,
                            override_generic_sorter  = true,
                            override_file_sorter     = true,
                            case_mode               = 'smart_case',
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
                            }),
                        },
                    },
                })
                telescope.load_extension('fzf')
                telescope.load_extension('ui-select')

                local builtin = require('telescope.builtin')
                vim.keymap.set({ 'n', 'v' }, '<C-p>',      builtin.find_files, {})
                vim.keymap.set({ 'n', 'v' }, '<leader>fb', builtin.buffers,    {})
                vim.keymap.set('n',          '<leader>ff', builtin.grep_string, {})
                vim.keymap.set({ 'n', 'v' }, '<leader>fs', function()
                    local data = global:selection()
                    if data == '' then
                        builtin.live_grep({})
                    else
                        builtin.live_grep({ default_text = data })
                    end
                end, {})
            end,
        },

        -- ── 悬浮终端 ───────────────────────────────────────────────────────
        {
            'akinsho/toggleterm.nvim',
            opts = {
                open_mapping = [[<F2>]],
                direction    = 'float',
            },
        },

        -- ── clang-format ───────────────────────────────────────────────────
        {
            'rhysd/vim-clang-format', ft = cppfilelist,
            init = function()
				global:install( {
					cmd  = 'clang-format',
					brew = 'clang-format',
					apt  = 'clang-format',
					yum  = 'clang-tools-extra',
				})
			end,
            config = function()
                vim.api.nvim_create_autocmd('FileType', {
                    pattern  = cppfilelist,
                    callback = function()
                        local opts = { noremap = true, buffer = true, silent = true }
                        vim.keymap.set('v', '<F3>', ':ClangFormat<cr>',       vim.tbl_extend('force', opts, { desc = 'CodeFormatV' }))
                        vim.keymap.set('n', '<F3>', ':<C-u>ClangFormat<cr>',  vim.tbl_extend('force', opts, { desc = 'CodeFormatN' }))
                    end,
                })
            end,
        },

        -- ── asyncrun ───────────────────────────────────────────────────────
        {
            'skywind3000/asyncrun.vim', ft = cppfilelist,
            config = function()
                vim.g.asyncrun_open = 6
                vim.g.asyncrun_bell = 1
            end,
            keys = {
                { '<F10>', ':call asyncrun#quickfix_toggle(6)<cr>', mode = 'n', desc = 'AsyncQuickfix',          noremap = true, silent = true },
                { '<F7>',  ':AsyncRun ./buildproject.sh<cr>',       mode = 'n', desc = 'AsyncBuild',             noremap = true, silent = true },
                { '<F8>',  ':AsyncRun ./buildproject.sh -e<cr>',    mode = 'n', desc = 'AsyncBuildExportConfig', noremap = true, silent = true },
                { '<F9>',  ':AsyncRun ./buildproject.sh -s<cr>',    mode = 'n', desc = 'AsyncBuildSqlbind',      noremap = true, silent = true },
            },
        },

        -- ── you complete me ───────────────────────────────────────────────
        -- {
		-- 	dir = localpath .. '/YouCompleteMe', ft = cppfilelist,
		-- 	config = function()
		-- 		vim.g.ycm_error_symbol = 'X'
		-- 		vim.g.ycm_warning_symbol = '?'
		-- 		vim.g.ycm_confirm_extra_conf = 0
		-- 		vim.g.ycm_show_diagnostics_ui = 1
		-- 		vim.g.ycm_max_diagnostics_to_display = 0
		-- 		vim.g.ycm_min_num_identifier_candidate_chars = 2
		-- 		vim.g.ycm_collect_identifiers_from_comments_and_strings = 1
		-- 		vim.g.ycm_seed_identifiers_with_syntax = 1
		-- 		vim.g.ycm_min_num_of_chars_for_completion = 1
		-- 		vim.g.ycm_key_invoke_completion = '<c-z>'
		-- 		if global.is_mac then
		-- 			-- macOS: 使用 xcrun 动态获取 Xcode clangd 路径
		-- 			local xcode_clangd = vim.fn.trim(vim.fn.system('xcrun -f clangd'))
		-- 			if vim.fn.executable(xcode_clangd) == 1 then
		-- 				vim.g.ycm_clangd_binary_path = xcode_clangd
		-- 			end
		-- 		elseif global.is_linux then
		-- 			-- Linux: 优先检查系统路径，如果不指定，YCM 将使用自带的 (如果是用 --clangd-completer 编译的话)
		-- 			local linux_clangd = '/usr/bin/clangd'
		-- 			if vim.fn.executable(linux_clangd) == 1 then
		-- 				vim.g.ycm_clangd_binary_path = linux_clangd
		-- 			end
		-- 		end
		-- 		vim.g.ycm_filetype_blacklist = "'tagbar' : 1,\
		-- 			'qf' : 1, 'notes' : 1, 'markdown' : 1, 'unite' : 1, \
		-- 			'text' : 1, 'vimwiki' : 1, 'pandoc' : 1, 'infolog' : 1, 'gitcommit' : 1, 'mail' : 1"
		-- 	end,
		-- 	keys = {
		-- 		{ '<F11>', ':YcmCompleter GoTo<cr>', mode = 'n', desc = 'YouCompleteMeGoto1', noremap = true, silent = true },
		-- 		{ '<F12>', ':YcmCompleter GoToImplementation<cr>', mode = 'n', desc = 'YouCompleteMeGoto2', noremap = true, silent = true },
		-- 	},
		-- },

        -- ── LSP (clangd) ───────────────────────────────────────────────────
        {
            'neovim/nvim-lspconfig',
            dependencies = { 'hrsh7th/cmp-nvim-lsp' },  -- 让 LSP 源码进入补全列表
            init = function()
				global:install( {
					cmd = 'clangd',
					brew = 'llvm',
					apt = 'clangd',
					yum = 'clang-tools-extra'
				})
			end,
            config = function()
                vim.lsp.config('clangd', {
                    cmd = {
                        'clangd',
                        '--background-index',
                        '--clang-tidy',
                        '--header-insertion=iwyu',
                        '-j=12',
                    },
                    root_dir = vim.fs.root(0, {
                        'compile_commands.json',
                        'build/compile_commands.json',
                        '.git',
                    }),
                    -- 在握手阶段就关闭语义高亮，不会有任何闪烁
                    on_init = function(client)
                        client.server_capabilities.semanticTokensProvider = nil
                    end,
                })
                vim.lsp.enable('clangd')                -- 显式启用该服务
            end,
        },

        -- ── 补全引擎 ───────────────────────────────────────────────────────
        {
            'hrsh7th/nvim-cmp',
            event = 'InsertEnter',                      -- 只有进入插入模式才加载，省内存
            dependencies = {
                'hrsh7th/cmp-nvim-lsp',
                'L3MON4D3/LuaSnip',                     -- 代码片段引擎
                'onsails/lspkind.nvim',
            },
            config = function()
                local cmp     = require('cmp')
                local lspkind = require('lspkind')
                cmp.setup({
                    formatting = {
                        format = lspkind.cmp_format({
                            mode = 'symbol_text',       -- 显示图标 + 文字
                            maxwidth = 50,              -- 自动截断长文本
                            ellipsis_char = '...',      -- 截断后缀
                            show_labelDetails = true,   -- 在较新的 nvim-cmp 中，可以把函数参数单列出来显示
                            menu = {
                                nvim_lsp = '●', buffer = '○', path = '󰉋', luasnip  = '⋗',
                            },
                        }),
                    },
                    snippet = {
                        expand = function(args) require('luasnip').lsp_expand(args.body) end,
                    },
                    mapping = cmp.mapping.preset.insert({
                        ['<C-b>']     = cmp.mapping.scroll_docs(-4),
                        ['<C-f>']     = cmp.mapping.scroll_docs(4),
                        ['<C-Space>'] = cmp.mapping.complete(),
                        ['<CR>']      = cmp.mapping.confirm({ select = true }),
                    }),
                    sources = cmp.config.sources({
                        { name = 'nvim_lsp' },
                    }),
                })
            end,
        },
    }
end

return develop
