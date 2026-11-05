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
