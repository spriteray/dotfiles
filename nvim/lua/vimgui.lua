local vimgui = {}

function vimgui.load(cppfilelist, scriptfilelist, scheme)
    return {

        -- ── 启动页 ─────────────────────────────────────────────────────────
        {
            'nvimdev/dashboard-nvim',
            dependencies = { 'nvim-tree/nvim-web-devicons' },
            opts = {
                theme        = 'hyper',
                disable_move = true,
                config = {
                    week_header = { enable = true },
                    project     = { enable = false },
                },
                hide = {                    -- 修复：原来变量未加引号
                    statusline = true,
                    tabline    = true,
                    winbar     = true,
                },
            },
        },

        -- ── diff 视图 ──────────────────────────────────────────────────────
        {
            'sindrets/diffview.nvim', opts = {},
        },

        -- ── 彩虹括号 ───────────────────────────────────────────────────────
        {
            'luochen1990/rainbow',
            init = function()
                vim.g.rainbow_active = 1
                vim.g.rainbow_conf   = {
                    ctermfgs = { 'darkblue', 'darkyellow', 'darkcyan', 'darkmagenta' },
                }
            end,
        },

        -- ── 缩进线 ─────────────────────────────────────────────────────────
        {
            'lukas-reineke/indent-blankline.nvim',
            main = 'ibl',
            ft   = cppfilelist,             -- 修复：原来 scriptsfilelist 拼写错误，且多余
            opts = {
                scope = {
                    enabled    = true,
                    show_start = true,
                    show_end   = false,
                },
            },
        },

        -- ── 文件树 ─────────────────────────────────────────────────────────
        {
            'nvim-neo-tree/neo-tree.nvim',
            dependencies = {
                'nvim-tree/nvim-web-devicons',
                'nvim-lua/plenary.nvim',
                'MunifTanjim/nui.nvim',
            },
            init = function()
                vim.g.neo_tree_remove_legacy_commands = 1
            end,
            opts = {
                close_if_last_window              = false,
                popup_border_style                = 'rounded',
                enable_git_status                 = true,
                enable_diagnostics                = true,
                open_files_do_not_replace_types   = { 'terminal', 'trouble', 'qf' },
                sort_case_insensitive             = false,
                default_component_configs = {
                    indent = { padding = 0, indent_size = 1 },
                    icon   = {
                        folder_closed = '',
                        folder_open   = '',
                        folder_empty  = '',
                        default       = '',
                    },
                },
            },
            keys = {
                { '<leader>ft', '<cmd>Neotree toggle<cr>', desc = 'NeoTree' },
            },
        },

        -- ── 状态栏, 标签栏 ────────────────────────────────────────────────────
        {
            'nvim-lualine/lualine.nvim',
            dependencies = { 'nvim-tree/nvim-web-devicons' },
            opts = {
                options = {
                    theme = 'auto',
                    globalstatus = true,
                    disabled_filetypes = {
                        winbar = {},
                        tabline = {},
                        statusline = { 'gitcommit' },
                    },
                },

                sections = { lualine_c = { 'filename' }, },

                tabline = {
                    lualine_a = {
                        {
                            'buffers',
                            mode = 2, -- 0: 只显示文件名, 2: 编号 + 文件名
                            symbols = {
                                modified = ' ●',
                                alternate_file = '',
                                directory = '',
                            },
                        },
                    },
                    lualine_z = { 'tabs', },
                },
            },
        }
    }
end

return vimgui
