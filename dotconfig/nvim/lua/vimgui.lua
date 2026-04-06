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

        -- ── 标签栏 ─────────────────────────────────────────────────────────
        {
            'akinsho/bufferline.nvim',
            dependencies = 'nvim-tree/nvim-web-devicons',
            config = function()
                local bl = require('bufferline')
                bl.setup({
                    options = {
                        style_preset = bl.style_preset.no_italic,
                        numbers      = true,
                        offsets = {
                            {
                                filetype   = 'neo-tree',
                                text       = 'File Explorer',
                                highlight  = 'Directory',
                                text_align = 'center',
                            },
                        },
                        custom_filter = function(buf)
                            local ft = vim.bo[buf].filetype
                            return ft ~= 'gitcommit' and ft ~= 'help' and ft ~= 'qf'
                        end,
                    },
                })
            end,
        },

        -- ── 状态栏 ─────────────────────────────────────────────────────────
        {
            'nvim-lualine/lualine.nvim',
            dependencies = { 'nvim-tree/nvim-web-devicons', opt = true },
            opts = {
                options = {
                    theme = scheme,
                    disabled_filetypes = {
                        winbar     = {},
                        tabline    = {},
                        statusline = { 'gitcommit' },
                    },
                },
            },
        },
    }
end

return vimgui
