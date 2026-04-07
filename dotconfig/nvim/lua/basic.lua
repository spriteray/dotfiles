-- ── Leader ────────────────────────────────────────────────────────────────
vim.g.mapleader = ','

-- ── 编辑行为 ───────────────────────────────────────────────────────────────
vim.opt.mouse       = 'a'
vim.opt.mousemodel  = 'popup'           -- 修复：原来缺少引号
vim.opt.selection   = 'inclusive'
vim.opt.magic       = true
vim.opt.wildmenu    = true
vim.opt.completeopt = { 'menu', 'menuone', 'noselect', 'longest' }
vim.opt.formatoptions = 'tcqmM'
vim.opt.autoindent  = true
vim.opt.smartindent = true
vim.opt.whichwrap:append('b,s,<,>,[,],h,l')

-- ── Tab / 缩进 ─────────────────────────────────────────────────────────────
vim.opt.tabstop    = 4
vim.opt.shiftwidth = 4
vim.opt.showtabline = 1

-- ── 文件 ───────────────────────────────────────────────────────────────────
vim.opt.autoread   = true
vim.opt.autowrite  = true
vim.opt.backup     = false
vim.opt.writebackup = false
vim.opt.swapfile   = false

-- ── 搜索 ───────────────────────────────────────────────────────────────────
vim.opt.incsearch  = true
vim.opt.ignorecase = true
vim.opt.smartcase  = true
vim.opt.syntax     = 'on'

-- ── UI ────────────────────────────────────────────────────────────────────
vim.opt.number         = true
vim.opt.cursorline     = true
vim.opt.splitbelow     = true
vim.opt.splitright     = false
vim.opt.termguicolors  = true
vim.opt.showmode       = false
vim.opt.signcolumn     = 'yes'
vim.opt.ruler          = true
vim.opt.showmatch      = true
vim.opt.scrolloff      = 3
vim.opt.sidescrolloff  = 3
vim.opt.updatetime     = 500        -- 加快 CursorHold 触发

-- ── 折叠 ───────────────────────────────────────────────────────────────────
vim.opt.foldenable  = true
vim.opt.foldlevel   = 100
vim.opt.foldmethod  = 'indent'
vim.opt.foldexpr    = ''

-- ── 不可见字符 ─────────────────────────────────────────────────────────────
vim.opt.list = true
vim.opt.listchars = {
    tab      = '» ',   -- 仅在开头显示一个小箭头，后面跟空格
    trail    = '·',   -- 行尾多余空格显示为小点
    nbsp     = '␣',
    extends  = '→',
    precedes = '←',
}

-- ── Python ─────────────────────────────────────────────────────────────────
vim.g.python3_host_prog = vim.env['PYTHON3_BIN']
