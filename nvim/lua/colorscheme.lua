
local colorscheme = {}

function colorscheme.load()
    return {
        -- colorschemes

        -- monokai
        'tomasr/molokai',

        -- nord
        'shaunsingh/nord.nvim',

        -- solarized
        {
            'maxmx03/solarized.nvim',
            main = { theme = 'neovim' },
        },

        -- gruvbox
        {
            'ellisonleao/gruvbox.nvim', dependencies = { 'rktjmp/lush.nvim' },
        }
    }
end

function colorscheme.apply( scheme, bg )
    local cmd = string.format( "set background=%s\ncolorscheme %s", bg, scheme )
    local is_ok,_ = pcall( vim.cmd, cmd )
    if not is_ok then
        vim.notify( 'colorscheme ' .. scheme .. ' not found !' )
    end
end

return colorscheme
