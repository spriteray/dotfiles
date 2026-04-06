local colorscheme = {}

-- ── 插件列表 ───────────────────────────────────────────────────────────────
function colorscheme.load()
    return {
        -- solarized（修复：原来 main 字段语法错误）
        {
            'maxmx03/solarized.nvim',
            opts = { theme = 'neovim' },
        },

        -- nightfox
        {
            'EdenEast/nightfox.nvim',
            opts = {
                options = {
                    terminal_colors = true,
                    styles = {
                        keywords = 'bold',
                        types    = 'bold',
                    },
                },
            },
        },

        -- tokyonight
        {
            'folke/tokyonight.nvim',
            opts = { transparent = false },
        },

        -- ayu
        'Shatur/neovim-ayu',

        -- gruvbox
        {
            'ellisonleao/gruvbox.nvim',
            dependencies = { 'rktjmp/lush.nvim' },
        },

        -- nord
        'rmehri01/onenord.nvim',

        -- molokai
        'tomasr/molokai',
    }
end

-- ── 应用配色 ───────────────────────────────────────────────────────────────
function colorscheme.apply_scheme(scheme)
    local cmd
    if scheme.background then
        cmd = string.format(
            'set background=%s\ncolorscheme %s', scheme.background, scheme.scheme )
    else
        cmd = string.format( 'colorscheme %s', scheme.scheme )
    end

    local ok, err = pcall(vim.cmd, cmd)
    if not ok then
        vim.notify('colorscheme ' .. scheme.scheme .. ' not found: ' .. tostring(err), vim.log.levels.WARN)
    end
end

return colorscheme
