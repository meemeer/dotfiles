set nocompatible

filetype plugin indent on
syntax enable

set t_Co=256
set t_Sf=[3%dm
set t_Sb=[4%dm
"colorscheme wombat256mod
"colorscheme xoria256

set ruler
set laststatus=2
set ignorecase
set smartcase

" Set standard setting for PEAR coding standards
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4

set nonumber
set foldmethod=marker
set foldclose=all
set noincsearch
set scrolljump=5
set scrolloff=3
set backspace=start,eol,indent
set modeline
"set smartindent
set wrapscan
set nolist
set showcmd
set showmatch
set hlsearch
noremap <Esc><Esc> :nohlsearch<CR><Esc>

set nobackup
set noswapfile

set statusline=%<[%n]%m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).':'.&ff.']'}%y\ %F%=%l,%c%V%8P

let html_use_css = 1

set wildmode=list:longest
set hidden
set autoread

"文字エンコードをutf-8に固定
"set fileencoding=utf-8
"set fileencodings=ucs-bom,utf-8,euc-jp,iso-2022-jp,cp932,utf-16,utf-16le

" 文字コードの自動認識
if &encoding !=# 'utf-8'
  set encoding=japan
  set fileencoding=japan
endif
if has('iconv')
  let s:enc_euc = 'euc-jp'
  let s:enc_jis = 'iso-2022-jp'
  " iconvがeucJP-msに対応しているかをチェック
  if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'eucjp-ms'
    let s:enc_jis = 'iso-2022-jp-3'
  " iconvがJISX0213に対応しているかをチェック
  elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'euc-jisx0213'
    let s:enc_jis = 'iso-2022-jp-3'
  endif
  " fileencodingsを構築
  if &encoding ==# 'utf-8'
    let s:fileencodings_default = &fileencodings
    if has('unix')
        let &fileencodings = s:enc_jis .','. s:enc_euc
        let &fileencodings = &fileencodings .','. s:fileencodings_default
    else
        let &fileencodings = s:enc_jis .','. s:enc_euc .',cp932'
        let &fileencodings = &fileencodings .','. s:fileencodings_default
    endif
    unlet s:fileencodings_default
  else
    let &fileencodings = &fileencodings .','. s:enc_jis
    set fileencodings+=utf-8,ucs-2le,ucs-2
    if &encoding =~# '^\(euc-jp\|euc-jisx0213\|eucjp-ms\)$'
      set fileencodings+=cp932
      set fileencodings-=euc-jp
      set fileencodings-=euc-jisx0213
      set fileencodings-=eucjp-ms
      let &encoding = s:enc_euc
      let &fileencoding = s:enc_euc
    else
      let &fileencodings = &fileencodings .','. s:enc_euc
    endif
  endif
  " 定数を処分
  unlet s:enc_euc
  unlet s:enc_jis
endif
" 日本語を含まない場合は fileencoding に encoding を使うようにする
if has('autocmd')
  function! AU_ReCheck_FENC()
    if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
      let &fileencoding=&encoding
    endif
  endfunction
  autocmd BufReadPost * call AU_ReCheck_FENC()
endif
" 改行コードの自動認識
set fileformats=unix,dos,mac
" □とか○の文字があってもカーソル位置がずれないようにする
if exists('&ambiwidth')
  set ambiwidth=double
endif

" cedit
set cedit=<C-O>

"表示行単位で行移動する
nmap j gj
nmap k gk
vmap j gj
vmap k gk

autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif
nmap ,e :execute '!' &ft ' %'<CR>
let g:SeeTabCtermFG="black"
let g:SeeTabCtermBG="red"
let g:netrw_ftp_cmd="netkit-ftp"
let g:netrw_http_cmd="wget -q -O"

" html escape function
:function HtmlEscape()
silent s/&/\&amp;/eg
silent s/</\&lt;/eg
silent s/>/\&gt;/eg
:endfunction

:function HtmlUnEscape()
silent s/&lt;/</eg
silent s/&gt;/>/eg
silent s/&amp;/\&/eg
:endfunction

" encoding
nmap ,U :set encoding=utf-8<CR>
nmap ,E :set encoding=euc-jp<CR>
nmap ,S :set encoding=cp932<CR>

"Omni補完のキー割り当て変更
"inoremap <C-F> <C-X><C-O>

hi Pmenu ctermbg=8
hi PmenuSel ctermbg=Blue
hi PmenuSbar ctermbg=10

" paste/nopaste
nmap ep :set paste<CR>
nmap enp :set nopaste<CR>

nmap ,l :call PHPLint()<CR>
function PHPLint()
    let result = system( &ft . ' -l ' . bufname(""))
    echo result
endfunction

"after/ftplugin/python.vimに記載
"let python_highlight_all=1
"autocmd FileType python setl autoindent
"autocmd FileType python setl smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
"autocmd FileType python setl tabstop=8 expandtab shiftwidth=4 softtabstop=4

" Execute python script C-P
function! s:ExecPy()
    exe "!" . &ft . " %"
:endfunction
command! Exec call <SID>ExecPy()
autocmd FileType python map <silent> <C-P> :call <SID>ExecPy()<CR>
