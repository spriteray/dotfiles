
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

let mapleader=","
let g:mapleader=","

" pathogen
call pathogen#infect()

set magic
set autoread
set autowrite
set history=400
set nocompatible
set makeprg=make\ all

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

" status line
"set laststatus=2
"set statusline=%f%m%r%h\ %w\ CWD:\ %{getcwd()}%h\ \ INFO:\ %{&ff}/%{&fenc!=''?&fenc:&enc}\ \ LINE:\ %l/%L:%c

" tab page
set showtabline=1
set tabline=%!MyTabLine()

" 代码折叠
set foldenable
set foldmethod=indent
set foldlevel=100
nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc':'zo')<CR>

filetype on
filetype plugin on
filetype indent on
" 文件类型
autocmd BufRead,BufNewFile *.md set filetype=markdown
autocmd BufRead,BufNewFile Makefile.* set filetype=makefile
" 4个SPACE替换TAB
autocmd FileType c,cpp,python 	set expandtab softtabstop=4	" C/C++/python 扩展TAB

" Qargs
command! -nargs=0 -bar Qargs execute 'args ' . QuickfixFilenames()

" 删除不放入剪切板
noremap <C-d> "_d

" molokai
" colorscheme molokai
" colorscheme onedark
set background=dark
colorscheme solarized

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
set tags=tags;
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
autocmd BufWritePre *.{c,h,cc,cpp,hpp,py,lua} call RemoveTrailingWhitespace()

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
		set background=light
        "set noantialias	                " Mac Anti-Alias
        set guifont=Droid\ Sans\ Mono:h14	" 字体
    endif
endif

"------------------------------
" Global Keymap Settings
"------------------------------

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

" ============================================================================
" => Plugins Settings
" ============================================================================

" air-line
let g:airline_theme="solarized"
"let g:airline_powerline_fonts = 1
"let g:airline#extensions#tabline#enabled = 1
"let g:airline#extensions#tabline#buffer_nr_show = 1

" cpp-enhanced
let g:cpp_class_scope_highlight = 0
let g:cpp_experimental_template_highlight = 0

" Tag List
let Tlist_Ctags_Cmd = $CMD_CTAGS
let Tlist_Show_One_File = 1
let Tlist_Exit_OnlyWindow = 1

" NERDTree
"let g:NERDTree_title='NERD Tree'
"let NERDTreeDirArrows = 0
"function! NERDTree_Start()
"	exec 'NERDTree'
"endfunction
"function! NERDTree_IsValid()
"	return 1
"endfunction

" Window Manager
let g:defaultExplorer = 0
let g:winManagerWidth = 40
let g:winManagerWindowLayout='FileExplorer|TagList'
"let g:winManagerWindowLayout='NERDTree|TagList'
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

" LeaderF
let g:Lf_ShortcutF = '<c-p>'
let g:Lf_ShortcutB = '<m-n>'
let g:Lf_StlSeparator = { 'left': '', 'right': '', 'font': '' }
let g:Lf_RootMarkers = ['.project', '.root', '.svn', '.git']
let g:Lf_WorkingDirectoryMode = 'Ac'
let g:Lf_WindowHeight = 0.30
let g:Lf_CacheDirectory = expand('~/.cache')
let g:Lf_ShowRelativePath = 0
let g:Lf_HideHelp = 1
let g:Lf_StlColorscheme = 'powerline'
let g:Lf_PreviewResult = {'Function':0, 'BufTag':0}
noremap <c-n> :LeaderfMru<cr>
noremap <m-p> :LeaderfFunction!<cr>
noremap <m-n> :LeaderfBuffer<cr>
noremap <m-m> :LeaderfTag<cr>

" gutentags
let g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']
let g:gutentags_ctags_tagfile = '.tags'
let s:vim_tags = expand('~/.cache/tags')
let g:gutentags_cache_dir = s:vim_tags
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']

" YouCompleteMe
set completeopt=menuone,menu,longest
nnoremap <F11> :YcmCompleter GoTo<CR>
nnoremap <F12> :YcmCompleter GoToDeclaration<CR>
let g:ycm_confirm_extra_conf = 0
let g:ycm_collect_identifiers_from_comments_and_strings = 1
let g:ycm_seed_identifiers_with_syntax = 1
let g:syntastic_always_populate_loc_list = 0
let g:ycm_min_num_of_chars_for_completion = 0
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
