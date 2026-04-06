local global = {}

-- ── 平台信息 ───────────────────────────────────────────────────────────────
function global:init()
    self.os_name   = vim.loop.os_uname().sysname
    self.is_mac    = self.os_name == 'Darwin'
    self.is_linux  = self.os_name == 'Linux'
    self.is_windows = self.os_name == 'Windows_NT'
    self.is_wsl    = vim.fn.has('wsl') == 1
end

-- ── 包管理器安装 ───────────────────────────────────────────────────────────
function global:install(app)
    if self.is_mac then
        vim.fn.system({ 'brew', 'install', app })
    elseif self.is_linux or self.is_wsl then
        vim.fn.system({ 'apt', 'install', app })
    else
        vim.notify('install ' .. app .. ' not supported on this platform')
    end
end

-- ── 获取 visual 选中文本 ───────────────────────────────────────────────────
function global:selection()
    vim.cmd('noau normal! "vy"')
    local text = vim.fn.getreg('v')
    vim.fn.setreg('v', {})
    text = string.gsub(text, '\n', '')
    return #text > 0 and text or ''
end

-- ── clangd 头文件/源文件互跳 ──────────────────────────────────────────────
function global:clangd_switch(split_cmd)
    local bufnr = vim.api.nvim_get_current_buf()
    local params = { uri = vim.uri_from_bufnr(bufnr) }
    vim.lsp.buf_request(bufnr, 'textDocument/switchSourceHeader', params,
        function(err, result)
            if err then
                vim.notify('LSP error: ' .. tostring(err), vim.log.levels.ERROR)
                return
            end
            if not result then
                vim.notify('对应的头文件/源文件未找到', vim.log.levels.WARN)
                return
            end
            if split_cmd then vim.cmd(split_cmd) end
            vim.cmd('edit ' .. vim.uri_to_fname(result))
        end
    )
end

-- ── 诊断 UI ────────────────────────────────────────────────────────────────
function global:diagnostic()
    vim.diagnostic.config({
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = '✘',
                [vim.diagnostic.severity.WARN]  = '▲',
                [vim.diagnostic.severity.HINT]  = '⚑',
                [vim.diagnostic.severity.INFO]  = '',
            },
        },
        virtual_text    = false,
        underline       = true,
        update_in_insert = false, -- 强制刷新当前缓冲区的显示
    })
end

-- ── 快捷键 ─────────────────────────────────────────────────────────────────
function global:keymap()
    local k = vim.keymap.set
    k('n', '<leader>c',  '<cmd>nohls<cr>', { desc = 'Clear HighLight' })
    k('n', '<leader>co', '<cmd>copen<cr>', { desc = 'Open qf Window' })
    k('n', '<leader>cc', '<cmd>cclose<cr>', { desc = 'Close qf Window' })
    k('n', '<leader>fd', '<cmd>set ff=dos<cr>', { desc = 'Set File-Format DOS' })
    k('n', '<leader>fu', '<cmd>set ff=unix<cr>', { desc = 'Set File-Format UNIX' })
    k('n', '<leader>fm', '<cmd>set ff=mac<cr>', { desc = 'Set File-Format MAC' })
    k('n', '<space>', "@=((foldclosed(line('.')) < 0) ? 'zc':'zo')<cr>", { desc = 'Code Fold', noremap = true })
end

-- ── autocmd ────────────────────────────────────────────────────────────────
function global:autocmd(cppfilelist, scriptfilelist)
    -- 修复：原来 register 调用时漏传 scriptfilelist

    -- a.vim 风格的 clangd 跳转命令
    vim.api.nvim_create_user_command('A',  function() self:clangd_switch() end, {})
    vim.api.nvim_create_user_command('AV', function() self:clangd_switch('vsplit') end, {})
    vim.api.nvim_create_user_command('AS', function() self:clangd_switch('split') end, {})
    vim.api.nvim_create_user_command('AT', function() self:clangd_switch('tabedit') end, {})

    -- cpp/script 文件：软 tab + 行末空白高亮
    local editgroup = vim.api.nvim_create_augroup('FileEditSettings', { clear = true })
    local allfiles = {}
    vim.list_extend(allfiles, cppfilelist)
    vim.list_extend(allfiles, scriptfilelist)

    vim.api.nvim_create_autocmd('FileType', {
        group   = editgroup,
        pattern = allfiles,     -- 修复：原来语法错误，两个列表要合并
        callback = function()
            vim.opt_local.softtabstop = 4
            vim.opt_local.expandtab   = true
            vim.api.nvim_set_hl(0, 'WhitespaceEOF', { bg = 'grey' })
            vim.fn.matchadd('WhitespaceEOF', [[\s\+$]])
        end,
    })

    -- 保存时自动清除行末空白
    vim.api.nvim_create_autocmd('BufWritePre', {
        group = editgroup,
        pattern = '*',
        callback = function()
            local view = vim.fn.winsaveview()
            vim.cmd([[keeppatterns %s/\s\+$//e]])
            vim.fn.winrestview(view)
        end,
    })

    -- 恢复上次光标位置
    vim.api.nvim_create_autocmd('BufReadPost', {
        group = editgroup,
        pattern = '*',
        callback = function()
            local line = vim.fn.line('\'"')
            if line > 0 and line <= vim.fn.line('$') then
                vim.cmd('normal! g`"')
            end
        end,
    })

    -- LSP attach：快捷键 + 关闭语义高亮（合并两个 LspAttach）
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
        callback = function(ev)
            local opts = { buffer = ev.buf }
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition,     opts)
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration,    opts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation,  opts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references,     opts)
            vim.keymap.set('n', 'K',  vim.lsp.buf.hover,          opts)
            vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
            -- 关闭语义高亮，避免覆盖 colorscheme
            -- local client = vim.lsp.get_client_by_id(ev.data.client_id)
            -- if client then
            --     client.server_capabilities.semanticTokensProvider = nil
            -- end
        end,
    })

    -- 光标停留时在底部显示诊断信息
    vim.api.nvim_create_autocmd('CursorHold', {
        group = editgroup,
        callback = function()
            local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
            local diagnostics = vim.diagnostic.get(0, { lnum = lnum })
            if #diagnostics > 0 then
                vim.api.nvim_echo({ { diagnostics[1].message, 'Normal' } }, false, {})
            end
        end,
    })
end

-- ── 对外入口 ───────────────────────────────────────────────────────────────
function global:register(cppfilelist, scriptfilelist)
    self:keymap()
    self:autocmd(cppfilelist, scriptfilelist)
end

return global
