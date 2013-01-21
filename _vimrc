
" =============================================================
" => General
" =============================================================

let mapleader=","
let g:mapleader=","

set nocompatible

set autoread
set history=400
filetype plugin on
filetype indent on
set t_Co=256
colorscheme molokai					" Theme

" Editing related
set number
set tabstop=4
set noexpandtab						" 不使用空格
set softtabstop=4
set shiftwidth=4
set cursorline
set showmatch
set backspace=indent,eol,start
set whichwrap=b,s,<,>,[,]
set mouse=a
set selectmode=
set mousemodel=popup
set keymodel=
set selection=inclusive
set smartindent						" 自动缩进
set cindent							" C样式的缩进

" Display related
set ru
set sm
set hls
set incsearch
set nowrapscan
set hlsearch
syntax on

" statusline
set laststatus=2
set statusline=%f%m%r%h\ %w\ CWD:\ %{getcwd()}%h\ \ INFO:\ %{&ff}/%{&fenc!=''?&fenc:&enc}\ \ LINE:\ %l/%L:%c

" 代码折叠
set foldenable
set foldmethod=indent
set foldlevel=100
nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc':'zo')<CR>

"------------------------------
" Platform Dependent Settings
"------------------------------

" OS Function
function! MyOS()
	if has("win32")
        return "windows"
    else
        let os=substitute(system('uname'), '\n', '', '')
        if os == 'Darwin' || os == 'Mac' || os == 'FreeBSD'
            return "bsd"
        else
            return "unix"
        endif
    endif
endfunction

" VIM Tools Settings
if MyOS() == "windows"
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
if MyOS() == "windows"
	set langmenu=zh_CN.UTF-8
	source $VIMRUNTIME/delmenu.vim
	source $VIMRUNTIME/menu.vim	
	language message zh_CN.UTF-8
endif

" 需要使用非UTF-8打开的项目
autocmd BufNewFile,BufRead */server/*.{c,h,cpp,py},*/server/*Makefile* set fileencoding=cp936
autocmd BufNewFile,BufRead */gameserver.git/*.{c,h,cpp,mk,conf},*/gameserver.git/*Makefile* set fileencoding=cp936
autocmd BufNewFile,BufRead */webgame.git/*.{c,h,cpp,mk,conf},*/webgame.git/*Makefile* set fileencoding=cp936
autocmd BufNewFile,BufRead */libevlite.git/*.{c,h,cpp},*/libevlite.git/*Makefile* set fileencoding=cp936

"------------------------------
" GUI Settings
"------------------------------

if has("gui_running")
    set guioptions-=m	" 隐藏菜单栏
    set guioptions-=T	" 隐藏工具栏
    set guioptions-=L	" 隐藏左侧滚动条
    set guioptions-=r	" 隐藏右侧滚动条
    set guioptions-=b	" 隐藏底部滚动条
	"set showtabline=2
	"set noantialias	" Mac Anti-Alias
	set nowrap	
	if MyOS() == "windows"
		set guifont=Lucida\ Sans\ Typewriter:h11
	else
		set guifont=andale\ mono:h14
		"set guifont=menlo:h14
	endif
	let psc_style='cool'
else
	set wrap
endif

"------------------------------
" Global Keymap Settings
"------------------------------

" Paste to Command Mode
"cmap	<C-p>	<C-r>"
" Save Tags
map		<F5>	:execute '!'.$CMD_CTAGS." -R --c++-kinds=+p --fields=+iaS --extra=+q" <CR>
" Explore Buffers
nmap	<Tab>	:buffers <CR>
" Shutdown HighLight
nmap <leader>c	:nohls <CR>

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

" Window Manager
let g:defaultExplorer = 0
let g:winManagerWidth = 40
let g:winManagerWindowLayout='FileExplorer|TagList'
map <silent> <F8> :WMToggle<CR> 
nmap <leader>wf :FirstExplorerWindow<CR>
nmap <leader>ws :BottomExplorerWindow<CR>

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
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'

" ============================================================================
" Functions
" ============================================================================

