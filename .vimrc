syntax on
set nobackup
set encoding=utf-8
set fileencoding=utf-8
"set fileencodings=iso-2022-jp,euc-jp,utf-8,ucs-2,cp932,sjis
set autoindent
set smartindent
set number
set incsearch
set ignorecase
set showmatch
set showmode
set title
set ruler
set tabstop=2
set shiftwidth=2
set hlsearch
set noswapfile
set visualbell t_vb=
set history=200
set expandtab

inoremap ( ()<ESC>i
inoremap <expr> ) ClosePair(')')
inoremap { {}<ESC>i
inoremap <expr> } ClosePair('}')
inoremap [ []<ESC>i
inoremap <expr> ] ClosePair(']')

function ClosePair(char)
     if getline('.')[col('.') - 1] == a:char
		 return "\<Right>"
	 else
		 return a:char
	 endif
endf

nmap <Esc><Esc> :nohlsearch<CR><Esc>

let g:neocomplcache_enable_at_startup = 1

let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"
inoremap <Esc> <Esc>

