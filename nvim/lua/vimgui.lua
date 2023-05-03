
local vimgui = {}

function vimgui.load()
    return {
        --
        -- colorscheme
        --

        -- colorscheme: monokai
        'tanvirtin/monokai.nvim',

        -- colorscheme: solarized
        {
            'maxmx03/solarized.nvim',
            main = { theme = 'neovim' },
            init = function()
                vim.o.background = 'light'
            end,
        },

        -- nvim-neo-tree
        {
            'nvim-neo-tree/neo-tree.nvim',
            dependencies = { 'nvim-tree/nvim-web-devicons', 'nvim-lua/plenary.nvim', 'MunifTanjim/nui.nvim' },
            init = function()
                vim.g.neo_tree_remove_legacy_commands = 1
            end,
            opts = {
                close_if_last_window = false,
                popup_border_style = "rounded",
                enable_git_status = true,
                enable_diagnostics = true,
                open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
                sort_case_insensitive = false,
            },
            keys = {
                { "<leader>ft", "<cmd>Neotree toggle<cr>", desc = "NeoTree" },
            },
        },

        -- bufferline
        {
            'akinsho/bufferline.nvim',
            dependencies = 'nvim-tree/nvim-web-devicons',
            config = function()
                local plugin = require( 'bufferline' )
                plugin.setup( {
                    options = {
                        separator_style = 'slant',
                        style_preset = plugin.style_preset.no_italic,
                        numbers = function(opts)
                            return string.format('%s|%s', opts.id, opts.raise(opts.ordinal))
                        end,
                        offsets = { {
                            filetype = 'neo-tree',
                            text = 'Explorer',
                            highlight = 'Directory',
                            text_align = 'center'
                        } },
                    },
                } ) 
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
                    disabled_filetypes = { statusline = {}, winbar = {}, 'neo-tree' },
                    ignore_focus = {},
                    always_divide_middle = true,
                    globalstatus = false,
                    refresh = { statusline = 1000, tabline = 1000, winbar = 1000, },
                },
                sections = {
                    lualine_a = {},
                    lualine_b = {'branch', 'diff', 'diagnostics'},
                    lualine_c = {'filename'},
                    lualine_x = {'encoding', 'fileformat', 'filetype'},
                    lualine_y = {'progress'},
                    lualine_z = {'location'}
                },
            },
        },
    }
end

return vimgui
