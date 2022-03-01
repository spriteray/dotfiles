
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

" QuickfixFilenames
function! QuickfixFilenames()
	" Building a hash ensures we get each buffer only once
	let buffer_numbers = {}
	for quickfix_item in getqflist()
		let buffer_numbers[quickfix_item.bufnr] = bufname(quickfix_item.bufnr)
	endfor
	return join(values(buffer_numbers))
endfunction

" ==============================================================================
" => General
" ==============================================================================

"------------------------------
" Platform Dependent Settings 
"------------------------------
if MyOS() == "win"
	let $VIMFILES 	= $VIM.'\vimfiles'
	let $VIMBINFILES= $VIMFILES.'\bin\'
	let $CMD_CTAGS	= $VIMBINFILES.'ctags.exe'
	let $CMD_GREP	= $VIMBINFILES.'grep.exe'
	let $CMD_FGREP	= $VIMBINFILES.'fgrep.exe'
	let $CMD_EGREP	= $VIMBINFILES.'egrep.exe'
	let $CMD_AGREP	= $VIMBINFILES.'grep.exe'
	let $CMD_FIND	= $VIMBINFILES.'find.exe'
elseif MyOS() == "unix"
	" VIMFILES
	let $VIMFILES	="$HOME/.vim"
	let $CMD_CTAGS	= 'ctags'
	let $CMD_GREP	= 'grep'
	let $CMD_FGREP	= 'fgrep'
	let $CMD_EGREP	= 'egrep'
	let $CMD_AGREP	= 'grep'
	let $CMD_FIND	= 'find'
else
	" VIMFILES
	let $VIMFILES	="$HOME/.vim"
	let $CMD_CTAGS	= '/usr/local/bin/ctags'
	let $CMD_GREP	= 'grep'
	let $CMD_FGREP	= 'fgrep'
	let $CMD_EGREP	= 'egrep'
	let $CMD_AGREP	= 'grep'
	let $CMD_FIND	= 'find'
endif

"------------------------------
" General Settings 
"------------------------------
let mapleader=","
let g:mapleader=","
set magic
set autoread
set autowrite
set history=400
set nocompatible
set makeprg=make\ all

" File Detecting
filetype on
filetype plugin on
filetype indent on
" Custom File Type 
autocmd BufRead,BufNewFile *.md set filetype=markdown
autocmd BufRead,BufNewFile Makefile.* set filetype=makefile

" Display related
set ru
set sm
set hls
set incsearch
set nowrapscan
set hlsearch
set t_Co=256
set showmatch 				" 括号配对
syntax on
set formatoptions=tcqmM
" tab page
set showtabline=1
set tabline=%!MyTabLine()
" status line
set laststatus=2
"set statusline=%f%m%r%h\ %w\ CWD:\ %{getcwd()}%h\ \ INFO:\ %{&ff}/%{&fenc!=''?&fenc:&enc}\ \ LINE:\ %l/%L:%c
" code fold 
set foldenable
set foldmethod=indent
set foldlevel=100

" Editing related
set number
set numberwidth=5
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
set cinoptions=s,e0,n0,f0,{0,}0,^0,L-1,:s,=s,l0,b0,g0,hs,N0,ps,ts,is,+s,c3,C0,/0,(2s,us,U0,w0,W0,k0,m0,j0,J0,)20,*70,#0
set autoindent
set smartindent									" 自动缩进

" Formats and Encoding relate
set ffs=unix,dos,mac
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
" Auto Command Settings 
"------------------------------

" 4个SPACE替换TAB
autocmd FileType c,cpp,python 	set expandtab softtabstop=4	" C/C++/python 扩展TAB

" 额外的配置
hi WhitespaceEOF ctermbg=grey guibg=grey
match WhitespaceEOF /\s\+$/

" Highlight TODO, FIXME, NOTE, etc.
autocmd Syntax * call matchadd('Todo',  '\W\zs\(TODO\|FIXME\|CHANGED\|BUG\|HACK\)')
autocmd Syntax * call matchadd('Debug', '\W\zs\(NOTE\|INFO\|IDEA\|NOTICE\)')

" 跳到退出之前的光标处
autocmd BufReadPost *
            \ if line("'\"") > 0 && line("'\"") <= line("$") |
            \ exe "normal! g`\"" |
            \ endif

" 自动去除行末空白
autocmd BufWritePre *.{c,h,cc,cpp,hpp,py,lua} call RemoveTrailingWhitespace()

"------------------------------
" Global Keymap Settings
"------------------------------

" Code Fold
nnoremap <space> 	@=((foldclosed(line('.')) < 0) ? 'zc':'zo')<CR>
" File-formats Exchange
nmap 	<leader>fd 	:se ff=dos<CR>
nmap 	<leader>fu 	:se ff=unix<CR>
nmap 	<leader>fm 	:se ff=mac<CR>
" 删除不放入剪切板
noremap <C-d> 		"_d
" Qargs
command! -nargs=0 -bar Qargs execute 'args ' . QuickfixFilenames()
" Shutdown HighLight
nmap	<leader>c	:nohls <CR>
" Tab Page
nmap	<C-t>		:tabnew %:p:h<CR>
" Ctrl-]
map 	<C-]> 		:tselect <C-R>=expand("<cword>")<CR><CR>
map 	<C-]> 		g<C-]>
"
nmap 	<leader>cw 	:cw<CR>
nmap 	<leader>cc 	:cclose<CR>
cmap    cwd         lcd %:p:h
cmap    cd.         lcd %:p:h

" ============================================================================
" => Plugins Settings
" ============================================================================
call plug#begin($VIMFILES.'/bundle')

" a.vim {
	Plug 'vim-scripts/a.vim', { 'for':['c', 'cpp', 'cc', 'h', 'hpp'] }
" }

" Rainbow {
	Plug 'luochen1990/rainbow'
	let g:rainbow_active = 1
	let g:rainbow_conf = { 'ctermfgs': ['darkblue', 'darkyellow', 'darkcyan', 'darkmagenta'] }
" }

" Cpp-Enhanced-Highlight {
	Plug 'octol/vim-cpp-enhanced-highlight', { 'for':['c', 'cpp', 'cc', 'h', 'hpp'] }
	let g:cpp_class_scope_highlight = 1
	let g:cpp_member_variable_highlight = 1
	let g:cpp_class_decl_highlight = 1
	let g:cpp_experimental_simple_template_highlight = 1
	let g:cpp_concepts_highlight = 1
" }

" ColorScheme {
	Plug 'tomasr/molokai'
	Plug 'altercation/vim-colors-solarized'
	" it appears as though colorscheme solarized 
	" must come somewhere after call plug#end()
	"set background=dark
	"colorscheme solarized
" }

" Airline {
	Plug 'vim-airline/vim-airline'
	Plug 'vim-airline/vim-airline-themes'
	let g:airline_theme='luna'
	"let g:airline_theme='solarized'
	"let g:airline_solarized_bg='light'
	"let g:airline_powerline_fonts = 1
	let g:airline#extensions#tabline#enabled = 1
	let g:airline#extensions#tabline#buffer_nr_show = 1
" }

" NERDTree {
	Plug 'scrooloose/nerdtree'
	"let g:NERDTree_title='NERD Tree'
	"let NERDTreeDirArrows = 0
	"function! NERDTree_Start()
	"	exec 'NERDTree'
	"endfunction
	"function! NERDTree_IsValid()
	"	return 1
	"endfunction
" }

" TagList.vim {
	Plug 'vim-scripts/taglist.vim'
	let Tlist_Ctags_Cmd = $CMD_CTAGS
	let Tlist_Show_One_File = 1
	let Tlist_Exit_OnlyWindow = 1
" }

" WinManager {
	Plug 'vim-scripts/winmanager'
	let g:defaultExplorer = 0
	let g:winManagerWidth = 40
	let g:winManagerWindowLayout='FileExplorer|TagList'
	"let g:winManagerWindowLayout='NERDTree|TagList'
	map <C-W><C-t>	:WMToggle<CR>
	map <C-W><C-f>	:FirstExplorerWindow<CR>
	map <C-W><C-b> 	:BottomExplorerWindow<CR>
" }

" Grep.vim {
	Plug 'vim-scripts/grep.vim'
	let Grep_Find_Use_Xargs = 0
	let Grep_Path = $CMD_GREP
	let Fgrep_Path = $CMD_FGREP
	let Egrep_Path = $CMD_EGREP
	let Agrep_Path = $CMD_AGREP
	let Grep_Find_Path = $CMD_FIND
	let Grep_Skip_Dirs = '.svn .git'
	nnoremap <silent> <leader>f : Grep<CR>
	nnoremap <silent> <leader>F : Rgrep<CR>
" }

Plug 'christoomey/vim-run-interactive'

" Asyncrun {
	Plug 'skywind3000/asyncrun.vim'
	set errorformat+=%E%f:%l:%c:\ error:%m,%Z%m
	set errorformat+=%-G%.%#
	let g:asyncrun_open = 6
	let g:asyncrun_bell = 1
	nnoremap <F10> :call asyncrun#quickfix_toggle(6)<cr>
	nnoremap <silent> <F7> :AsyncRun ./buildproject.sh<cr>
" } 

" gutentags {
	"Plug 'ludovicchabant/vim-gutentags', { 'for':['c', 'cpp', 'cc', 'h', 'hpp'] }
	"let g:gutentags_trace = 1
	"let g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']
	"let g:gutentags_ctags_tagfile = '.tags'
	"let s:vim_tags = expand('~/.cache/tags')
	"let g:gutentags_cache_dir = s:vim_tags
	"let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
	"let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
	"let g:gutentags_ctags_extra_args += ['--c-kinds=+px']
" }

" clang-format {
	Plug 'rhysd/vim-clang-format'
	let g:clang_format#code_style='webkit'
	let g:clang_format#style_options = {
				\ "Standard" : "Latest",
				\ "SortIncludes" : "false",
				\ "AccessModifierOffset" : -4,
				\ "AllowAllArgumentsOnNextLine" : "true",
				\ "AllowAllConstructorInitializersOnNextLine" : "true",
				\ "AllowShortLambdasOnASingleLine" : "true",
				\ "AllowShortCaseLabelsOnASingleLine" : "true",
				\ "AllowShortBlocksOnASingleLine" : "true",
				\ "AllowShortLoopsOnASingleLine" : "true",
				\ "AllowShortFunctionsOnASingleLine" : "Inline",
				\ "AllowShortIfStatementsOnASingleLine" : "WithoutElse",
				\ "AlwaysBreakTemplateDeclarations" : "No",
				\ "PointerAlignment" : "Middle",
				\ "AlignTrailingComments" : "true",
				\ "BinPackArguments" : "false",
				\ "FixNamespaceComments" : "true",
				\ "NamespaceIndentation" : "Inner",
				\ "SpaceInEmptyParentheses" : "false",
				\ "SpaceInEmptyBlock" : "false",
				\ "SpacesInConditionalStatement" : "true",
				\ "SpacesInParentheses" : "true",
				\ "SpacesInContainerLiterals" : "true",
				\ "SpaceBeforeAssignmentOperators" : "true",
				\ "SpaceBeforeInheritanceColon" : "true",
				\ "SpaceBeforeCtorInitializerColon" : "true",
				\ "SpaceBeforeRangeBasedForLoopColon" : "true",
				\ "SpaceAfterTemplateKeyword" : "false",
				\ "IndentCaseLabels" : "true", 
				\ "BreakBeforeBinaryOperators" : "All", 
				\ "BreakConstructorInitializers" : "BeforeColon", 
				\ "BreakBeforeBraces" : "Mozilla", 
				\ }
	autocmd FileType c,cpp,objc nnoremap <buffer><F3> :<C-u>ClangFormat<CR>
	autocmd FileType c,cpp,objc vnoremap <buffer><F3> :ClangFormat<CR>
" }

" LeaderF {
	Plug 'Yggdroot/LeaderF'
	let g:Lf_ShortcutF = '<c-p>'
	let g:Lf_ShortcutB = '<m-n>'
	let g:Lf_WindowPosition = 'popup'
	let g:Lf_PreviewInPopup = 1
	noremap <c-n> :LeaderfMru<cr>
	noremap <m-p> :LeaderfFunction!<cr>
	noremap <m-n> :LeaderfBuffer<cr>
	noremap <m-m> :LeaderfTag<cr>
	let g:Lf_StlSeparator = { 'left': '', 'right': '', 'font': '' }
	let g:Lf_RootMarkers = ['.project', '.root', '.svn', '.git']
	let g:Lf_WorkingDirectoryMode = 'Ac'
	let g:Lf_WindowHeight = 0.30
	let g:Lf_CacheDirectory = expand('~/.cache')
	let g:Lf_ShowRelativePath = 0
	let g:Lf_HideHelp = 1
	let g:Lf_StlColorscheme = 'powerline'
	let g:Lf_PreviewResult = {'Function':0, 'BufTag':0}
	let g:Lf_CommandMap = {'<C-K>': ['<Up>'], '<C-J>': ['<Down>']}
" }

" YouCompleteMe {
	Plug $VIMFILES.'/bundle/YouCompleteMe', { 'for':['c', 'cpp', 'cc', 'h', 'hpp'] }
	set completeopt=menuone,menu,longest
	nnoremap <F11> :YcmCompleter GoTo<CR>
	nnoremap <F12> :YcmCompleter GoToDeclaration<CR>
	let g:ycm_error_symbol = 'X'
	let g:ycm_warning_symbol = '?'
	let g:ycm_confirm_extra_conf = 0
	let g:ycm_min_num_identifier_candidate_chars = 2
	let g:ycm_collect_identifiers_from_comments_and_strings = 1
	let g:ycm_seed_identifiers_with_syntax = 1
	let g:ycm_min_num_of_chars_for_completion = 1
	let g:ycm_key_invoke_completion = '<c-z>'
	let g:ycm_filetype_blacklist = {
	      \ 'tagbar' : 1,
	      \ 'qf' : 1,
	      \ 'notes' : 1,
	      \ 'markdown' : 1,
	      \ 'unite' : 1,
	      \ 'text' : 1,
	      \ 'vimwiki' : 1,
	      \ 'pandoc' : 1,
	      \ 'infolog' : 1,
	      \ 'gitcommit' : 1,
	      \ 'mail' : 1
	      \}
" }

call plug#end()

" ============================================================================
" => UI Settings 
" ============================================================================
if has("gui_running")
	" GUI
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
		set background=light				" 背景色
        set guifont=Go\ Mono:h14			" 字体
    endif
else
	set background=light 					" 背景色
	" colorscheme solarized
endif

