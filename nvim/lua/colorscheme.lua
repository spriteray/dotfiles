
local colorscheme = {}

function colorscheme.load()
    return {
        -- colorschemes

        -- monokai
        'tomasr/molokai',

        -- nord
        'rmehri01/onenord.nvim',

        -- solarized
        {
            'maxmx03/solarized.nvim',
            main = { theme = 'neovim' },
        },

        -- nightfox
        {
            'EdenEast/nightfox.nvim',
            opts = {
                options = {
                    styles = {
                        -- comments = 'italic',
                        keywords = "bold",
                        types = "bold",
                    },

                },
            },
        },

        -- gruvbox
        {
            'ellisonleao/gruvbox.nvim', dependencies = { 'rktjmp/lush.nvim' },
        },

        -- tokyo night
        {
            'folke/tokyonight.nvim',
            opts = {
                style = 'storm',
                transparent = false,
            },
        },
    }
end

function colorscheme.apply( scheme )
    local cmd = string.format( "set background=%s\ncolorscheme %s", scheme.background, scheme.scheme )
    local is_ok,_ = pcall( vim.cmd, cmd )
    if not is_ok then
        vim.notify( 'colorscheme ' .. scheme.scheme .. ' not found !' )
    end
end

-- 选择主题
function colorscheme.apply_scheme( scheme )
    local global = require( 'global' )
	colorscheme.apply( scheme )
end

return colorscheme
