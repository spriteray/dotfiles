
local global = {}

function global:init()
    self.os_name = vim.loop.os_uname().sysname
    self.is_mac = self.os_name == 'Darwin'
    self.is_linux = self.os_name == 'Linux'
    self.is_windows = self.os_name == 'Windows_NT'
    self.is_wsl = vim.fn.has( 'wsl' ) == 1
end

function global:install( app )
    if self.is_mac then
        vim.fn.system( { 'brew', 'install', app } )
    elseif self.is_linux then
        vim.fn.system( { 'apt', 'install', app } )
    elseif self.is_wsl then
        vim.fn.system( { 'apt', 'install', app } )
    else
        vim.notify( 'install ' .. app .. ' failed!' )
    end
end

function global:selection()
    vim.cmd('noau normal! "vy"')
    local text = vim.fn.getreg("v")
    vim.fn.setreg("v", {})

    text = string.gsub(text, "\n", "")
    if #text > 0 then
        return text
    else
        return ""
    end
end

-- 定义一个函数来处理 clangd 的切换并支持分割窗口
function global:clangd_switch(split_cmd)
  local bufnr = vim.api.nvim_get_current_buf()
  -- 调用 clangd 扩展 API
  vim.lsp.buf_request(bufnr, 'textDocument/switchSourceHeader', { uri = vim.uri_from_bufnr(bufnr) }, function(err, result)
    if err then
      print("LSP error: " .. tostring(err))
      return
    end
    if not result then
      print("对应的头文件/源文件未找到")
      return
    end

    -- 如果需要分割窗口 (如 AV, AS)
    if split_cmd then
      vim.cmd(split_cmd)
    end

    -- 跳转到目标文件
    vim.api.nvim_command('edit ' .. vim.uri_to_fname(result))
  end)
end

function global:autocmd( cppfilelist, scriptfilelist )
	-- 注册模拟 a.vim 的命令
	vim.api.nvim_create_user_command('A', function() self:clangd_switch() end, {})
	vim.api.nvim_create_user_command('AV', function() self:clangd_switch('vsplit') end, {})
	vim.api.nvim_create_user_command('AS', function() self:clangd_switch('split') end, {})
	vim.api.nvim_create_user_command('AT', function() self:clangd_switch('tabedit') end, {})
    -- 高亮显示行末空白
    vim.api.nvim_create_autocmd( 'FileType', {
        pattern = cppfilelist, scriptfilelist,
        callback = function()
            -- number of spacesin tab when editing
            vim.opt.softtabstop = 4
            -- tabs are spaces, mainly because of python
            vim.opt.expandtab = true
            vim.api.nvim_exec( [[
                hi WhitespaceEOF ctermbg=grey guibg=grey
                match WhitespaceEOF /\s\+$/
            ]], true )
        end
    } )
    -- 自动移除行末空白
    vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = '*',
        callback = function()
            vim.api.nvim_exec( [[
                function! NoWhitespace()
                    let l:save = winsaveview()
                    keeppatterns %s/\s\+$//e
                    call winrestview(l:save)
                endfunction
                call NoWhitespace()
            ]], true )
        end
    })
    -- 跳到退出之前的光标处
    vim.api.nvim_create_autocmd( 'BufReadPost', {
        pattern = '*',
        callback = function()
            vim.api.nvim_exec( [[
                if line("'\"") > 0 && line("'\"") <= line("$")
                    exe "normal! g`\""
                endif
            ]], true )
        end
    })
	vim.api.nvim_create_autocmd("ColorScheme", {
		pattern = "solarized", -- 确保这里的模式名与你的配色一致
		callback = function()
			-- 将不可见字符设置为较浅的颜色，适配 Solarized Light 背景
			-- guifg 为十六进制颜色，ctermfg 为终端颜色码
			vim.api.nvim_set_hl(0, "NonText", { fg = "#93a1a1", ctermfg = 246 })
			vim.api.nvim_set_hl(0, "SpecialKey", { fg = "#93a1a1", ctermfg = 246 })
		end,
	})
	-- lsp
	vim.api.nvim_create_autocmd('LspAttach', {
		group = vim.api.nvim_create_augroup('UserLspConfig', {}),
		callback = function(ev)
			-- 这里的 opts 确保快捷键只在当前开启了 LSP 的 buffer 中生效
			local opts = { buffer = ev.buf }
			-- 跳转到定义 (Definition)
			vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
			-- 跳转到声明 (Declaration)
			vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
			-- 跳转到实现 (Implementation) - 比如虚函数实现
			vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
			-- 查看引用 (References)
			vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
			-- 悬停显示文档 (Hover)
			vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
			-- 符号重命名 (Rename)
			vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
		end,
	})
	-- 实现“光标移动到报错行，在底部显示错误描述”
	vim.api.nvim_create_autocmd("CursorHold", {
		callback = function()
			-- 获取当前光标下的所有诊断信息
			local opts = {
				focusable = false,
				close_events = { "CursorMoved", "CursorMovedI", "BufHidden", "InsertEnter" },
				scope = 'line',
			}
			-- 方式 A：弹出悬浮窗（体验最好，不遮挡代码）
			-- vim.diagnostic.open_float(nil, opts)

			-- 方式 B：直接在最底部的 echo 区域显示（满足你的需求）
			local diagnostics = vim.diagnostic.get(0, { lnum = vim.api.nvim_win_get_cursor(0)[1] - 1 })
			if #diagnostics > 0 then
				local msg = diagnostics[1].message
				-- 加上颜色高亮（根据严重程度）
				vim.api.nvim_echo({{msg, "Normal"}}, false, {})
			end
		end
	})
end

function global:keymap()
    vim.keymap.set( 'n', '<leader>c',  '<cmd>nohls<cr>', { desc = 'Clear HighLight' } )
    vim.keymap.set( 'n', '<leader>co', '<cmd>:copen<cr>', { desc = 'Open qf Window' } )
    vim.keymap.set( 'n', '<leader>cc', '<cmd>:cclose<cr>', { desc = 'Close qf Window' } )
    vim.keymap.set( 'n', '<leader>fd', '<cmd>:set ff=dos<cr>',{ desc = 'Set File-Format DOS' } )
    vim.keymap.set( 'n', '<leader>fu', '<cmd>:set ff=unix<cr>', { desc = 'Set File-Format UNIX' } )
    vim.keymap.set( 'n', '<leader>fm', '<cmd>:set ff=mac<cr>', { desc = 'Set File-Format MAC' } )
    vim.keymap.set( 'n', '<space>', "@=((foldclosed(line('.')) < 0) ? 'zc':'zo')<cr>", { desc = 'Code Fold', noremap = true } )
end

function global:diagnostic()
	local icons = {
        [vim.diagnostic.severity.ERROR] = "✘",
        [vim.diagnostic.severity.WARN]  = "▲",
        [vim.diagnostic.severity.HINT]  = "⚑",
        [vim.diagnostic.severity.INFO]  = "",
    }
    vim.diagnostic.config({
        signs = { text = icons },
        virtual_text = false,
        underline = true,
        -- 强制刷新当前缓冲区的显示
        update_in_insert = false,
    })
end

function global:register( cppfilelist )
    self:keymap()
    self:autocmd( cppfilelist )
end

return global
