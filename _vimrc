
" ==============================================================================
" => Functions
" ==============================================================================

" OS Function
function! MyOS()
	if has("win32")
        return "win"
    else
        let os=substitute(system('uname'), '\n', '', '')
        if os == 'Darwin' || os == 'Mac'
            return "mac"
        elseif os == 'FreeBSD'
            return "bsd"
        else
            return "unix"
        endif
    endif
endfunction

" Tab Page
function! MyTabLine()
	let s = ''
	let t = tabpagenr()
	let i = 1
	while i <= tabpagenr('$')
		let buflist = tabpagebuflist(i)
		let winnr = tabpagewinnr(i)
		let s .= '%' . i . 'T'
		let s .= (i == t ? '%1*' : '%2*')
		let s .= ' '
		let s .= i . ')'
		let s .= ' %*'
		let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')
		let file = bufname(buflist[winnr - 1])
		let file = fnamemodify(file, ':p:t')
		if file == ''
			let file = '[No Name]'
		endif
		let s .= file
		let i = i + 1
	endwhile
	let s .= '%T%#TabLineFill#%='
	let s .= (tabpagenr('$') > 1 ? '%999XX' : 'X')
	return s
endfunction

" Remove trailing whitespace when writing a buffer
function! RemoveTrailingWhitespace()
    if &ft != "diff"
        let b:curcol = col(".")
        let b:curline = line(".")
        silent! %s/\s\+$//
        silent! %s/\(\s*\n\)\+\%$//
        call cursor(b:curline, b:curcol)
    endif
endfunction

" ==============================================================================
" => General
" ==============================================================================

let mapleader=","
let g:mapleader=","

" pathogen
call pathogen#infect()

set autoread
set history=400
set nocompatible
filetype on
filetype plugin on
filetype indent on
syntax on

" Display related
set ru
set sm
set hls
set incsearch
set nowrapscan
set hlsearch
set t_Co=256
set showmatch

" Editing related
set number
set tabstop=4
set shiftwidth=4
set cursorline
"set cursorcolumn			" 设置光标十字坐标，高亮当前列
set backspace=indent,eol,start
set whichwrap=b,s,<,>,[,]
set mouse=a
set selectmode=
set mousemodel=popup
set keymodel=
set selection=inclusive
set cindent										" C样式的缩进
set autoindent
set smartindent									" 自动缩进
" 4个SPACE替换TAB
autocmd FileType c 		set expandtab softtabstop=4	" C/C++ 扩展TAB
autocmd FileType cpp 	set expandtab softtabstop=4	" C/C++ 扩展TAB
autocmd FileType python set expandtab softtabstop=4	" Python扩展TAB

" status line
set laststatus=2
set statusline=%f%m%r%h\ %w\ CWD:\ %{getcwd()}%h\ \ INFO:\ %{&ff}/%{&fenc!=''?&fenc:&enc}\ \ LINE:\ %l/%L:%c

" tab page
set showtabline=1
set tabline=%!MyTabLine()

" 代码折叠
set foldenable
set foldmethod=indent
set foldlevel=100
nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc':'zo')<CR>

" color scheme
colorscheme molokai
"set background=dark
"let g:solarized_italic=0
"let g:solarized_termtrans=1
"let g:solarized_termcolors=256
"colorscheme solarized
" 额外的配置
hi WhitespaceEOF ctermbg=grey guibg=grey
match WhitespaceEOF /\s\+$/

"------------------------------
" Platform Dependent Settings
"------------------------------

" VIM Tools Settings
if MyOS() == "win"
	let $VIMBINFILES = $VIM.'\vimfiles\bin\'
	let $CMD_CTAGS	= $VIMBINFILES.'ctags.exe'
	let $CMD_GREP	= $VIMBINFILES.'grep.exe'
	let $CMD_FGREP	= $VIMBINFILES.'fgrep.exe'
	let $CMD_EGREP	= $VIMBINFILES.'egrep.exe'
	let $CMD_AGREP	= $VIMBINFILES.'grep.exe'
	let $CMD_FIND	= $VIMBINFILES.'find.exe'
elseif MyOS() == "unix"
	let $CMD_CTAGS	= 'ctags'
	let $CMD_GREP	= 'grep'
	let $CMD_FGREP	= 'fgrep'
	let $CMD_EGREP	= 'egrep'
	let $CMD_AGREP	= 'grep'
	let $CMD_FIND	= 'find'
else
	let $CMD_CTAGS	= '/usr/local/bin/ctags'
	let $CMD_GREP	= 'grep'
	let $CMD_FGREP	= 'fgrep'
	let $CMD_EGREP	= 'egrep'
	let $CMD_AGREP	= 'grep'
	let $CMD_FIND	= 'find'
endif

" ctags cmd line
let $CTAGS_CMD_LINE = '!'.$CMD_CTAGS." -R --c-kinds=+p --c++-kinds=+p --fields=+iaS --extra=+q"

" Auto-Refresh Tags File
autocmd BufWritePost *.{c,h,cpp,cc,hpp}
			\ if filewritable("tags") |
			\	silent execute $CTAGS_CMD_LINE |
			\ endif

" 跳到退出之前的光标处
autocmd BufReadPost *
            \ if line("'\"") > 0 && line("'\"") <= line("$") |
            \ exe "normal! g`\"" |
            \ endif

" 自动去除行末空白
autocmd BufWritePre * call RemoveTrailingWhitespace()

"------------------------------
" File Formats And Encodings
"------------------------------

" Formats relate
set ffs=unix,dos,mac
nmap <leader>fd :se ff=dos<CR>
nmap <leader>fu :se ff=unix<CR>
nmap <leader>fm :se ff=mac<CR>

" Encoding relate
set encoding=utf-8					" vim内部编码
set termencoding=utf-8				" 终端以及系统编码
set fileencoding=utf-8				" 默认文件编码utf-8
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1

" 需要使用非UTF-8打开的项目
"autocmd BufNewFile,BufRead */server/*.{c,h,cpp,py},*/server/*Makefile* set fileencoding=cp936
"autocmd BufNewFile,BufRead */gameserver.git/*.{c,h,cpp,mk,conf},*/gameserver.git/*Makefile* set fileencoding=cp936
"autocmd BufNewFile,BufRead */webgame.git/*.{c,h,cpp,mk,conf},*/webgame.git/*Makefile* set fileencoding=cp936
"autocmd BufNewFile,BufRead */actgame.git/*.{c,h,cpp,mk,conf},*/actgame.git/*Makefile* set fileencoding=cp936
"autocmd BufNewFile,BufRead */libevlite.git/*.{c,h,cpp},*/libevlite.git/*Makefile* set fileencoding=cp936

"------------------------------
" GUI Settings
"------------------------------

if has("gui_running")
    set guioptions-=m	" 隐藏菜单栏
    set guioptions-=T	" 隐藏工具栏
    set guioptions-=L	" 隐藏左侧滚动条
    set guioptions-=r	" 隐藏右侧滚动条
    set guioptions-=b	" 隐藏底部滚动条
    set guioptions-=e	" 隐藏底部滚动条
    " OS Gui Layout
    if MyOS() == "win"
        set langmenu=zh_CN.UTF-8
        source $VIMRUNTIME/delmenu.vim
        source $VIMRUNTIME/menu.vim
        language message zh_CN.UTF-8
        set guifont=Lucida\ Console:h10.5   " 字体
    elseif MyOS() == "mac"
        set macmeta                         " Mac Alt-Key
        "set noantialias	                " Mac Anti-Alias
        set guifont=andale\ mono:h14        " 字体
    endif
endif

"------------------------------
" Global Keymap Settings
"------------------------------

" Paste to Command Mode
"cmap	<C-p>	<C-r>"
" Save Tags
"map		<F5>		:execute $CTAGS_CMD_LINE<CR>
" Shutdown HighLight
nmap	<leader>c	:nohls <CR>
" Tab Page
nmap	<C-t>		:tabnew %:p:h<CR>
" Ctrl-]
map 	<C-]> 		:tselect <C-R>=expand("<cword>")<CR><CR>
map 	<C-]> 		g<C-]>

" ============================================================================
" => Plugins Settings
" ============================================================================

" Tag List
let Tlist_Ctags_Cmd = $CMD_CTAGS
let Tlist_Show_One_File = 1
let Tlist_Exit_OnlyWindow = 1

" Mini Buffer Explorer
"let g:miniBufExplMapCTabSwitchBufs = 1
"let g:miniBufExplMapWindowNavArrows = 1

" NERDTree
let g:NERDTree_title='NERD Tree'
let NERDTreeDirArrows = 0
function! NERDTree_Start()
	exec 'NERDTree'
endfunction
function! NERDTree_IsValid()
	return 1
endfunction

" Window Manager
let g:defaultExplorer = 0
let g:winManagerWidth = 40
"let g:winManagerWindowLayout='FileExplorer|TagList'
let g:winManagerWindowLayout='NERDTree|TagList'
map <C-W><C-t>	:WMToggle<CR>
map <C-W><C-f>	:FirstExplorerWindow<CR>
map <C-W><C-b> 	:BottomExplorerWindow<CR>

" Grep
let Grep_Find_Use_Xargs = 0
let Grep_Path = $CMD_GREP
let Fgrep_Path = $CMD_FGREP
let Egrep_Path = $CMD_EGREP
let Agrep_Path = $CMD_AGREP
let Grep_Find_Path = $CMD_FIND
let Grep_Skip_Dirs = '.svn .git'
nnoremap <silent> <leader>f : Grep<CR>
nnoremap <silent> <leader>F : Rgrep<CR>
nmap <leader>cw :cw<CR>
nmap <leader>cc :cclose<CR>

" Omni
let OmniCpp_DefaultNamespaces = ["std"]
let OmniCpp_GlobalScopeSearch = 1 " 0 or 1
let OmniCpp_NamespaceSearch = 1 " 0 , 1 or 2
let OmniCpp_DisplayMode = 1
let OmniCpp_ShowScopeInAbbr = 0
let OmniCpp_ShowPrototypeInAbbr = 1
let OmniCpp_ShowAccess = 0
let OmniCpp_MayCompleteDot = 1
let OmniCpp_MayCompleteArrow = 1
let OmniCpp_MayCompleteScope = 1
set completeopt=menuone,menu,longest

" CtrlP
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = ''
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.d,*.o
set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe,*.d,*.o
