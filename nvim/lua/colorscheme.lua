
local colorscheme = {}

function colorscheme.load()
    return {
        -- colorschemes

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
    }
end

function colorscheme.apply( scheme )
    local curscheme = "colorscheme " .. scheme
    local is_ok,_ = pcall( vim.cmd, curscheme )
    if not is_ok then
        vim.notify( curscheme .. ' not found !' )
    end
end

return colorscheme
