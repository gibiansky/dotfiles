" Main Vim configuration file "

" ****************************************************************************** "
" Note: 
"   This is my personal .vimrc file; copying the entire thing is a bad idea,
"   as it might produce weird side effects. To make it more readable, the top
"   section is restricted to easy to understand one-line configurations; 
"   anything that takes more than that is separated into a function or separate
"   source file. 
" ****************************************************************************** "


function! VimSetup()
" ************************   Quick Config   ************************************ "

" Home directory "
let g:home=system("printf $HOME")

" Already ran setup "
let g:ran_setup=1

" Allow modelines "
set modeline

" Line numbers "
set number           " Required to have current line number not be just zero
set relativenumber

set backspace=indent,start

" Give me a reasonable history
set history=1000

" Not compatible with Ex "
set nocompatible

" Remove menu bar
set guioptions-=m

" Remove toolbar
set guioptions-=T

" Display a statusline always
set laststatus=2
set statusline=%10f:        " Filename (padded to 10 characters)
set statusline+=\ %4l/%.4L  " Current line / Total lines (padded to 4 chars)
set statusline+=\ -\ %2c    " Current character number

" Automatically swith directories per tab
set autochdir

" Vundle "
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'

Bundle 'gibiansky/vim-latex-objects'
Bundle 'jcf/vim-latex'

" Include bundles "
Bundle 'Raimondi/delimitMate'
Bundle 'jnwhiteh/vim-golang'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-repeat'
Bundle 'hynek/vim-python-pep8-indent'
Bundle 'gaving/vim-textobj-argument'
Bundle 'kchmck/vim-coffee-script'
Bundle 'michaeljsmith/vim-indent-object'

Bundle "MarcWeber/vim-addon-mw-utils"
Bundle "tomtom/tlib_vim"

Bundle 'SirVer/ultisnips'
Bundle 'honza/vim-snippets'
let g:UltiSnipsExpandTrigger = '<c-j>'

Bundle 'Valloric/YouCompleteMe'
let g:ycm_allow_changing_updatetime = 0

Bundle 'godlygeek/tabular'
function! InputChar()
    let c = getchar()
    return type(c) == type(0) ? nr2char(c) : c
endfunction

Bundle 'Floobits/floobits-vim'
set updatetime=100

" Ctrl-P file finder
Bundle 'kien/ctrlp.vim'
let g:ctrlp_extensions = ['line', 'mixed']
let g:ctrlp_map = '<c-n>'
let g:ctrlp_cmd = 'CtrlP /Users/silver'
let g:ctrlp_working_path_mode=0
let g:ctrlp_show_hidden=1
let g:ctrlp_prompt_mappings = {
    \ 'AcceptSelection("h")': ['<c-g>'],
    \ }
" Don't regenerate the cache every time
let g:ctrlp_clear_cache_on_exit = 0

" Places for Ctrl-P to ignore
let ignore_dirs = ["\\.git", "\\.hg", "\\.svn", "\\.cache", "\\.ghc", "\\.gem", "\\.shelly", "\\.text",
                  \"\\.cabal", "\\.ipynb_checkpoints", "stuff", "\\.matlab", "\\.ipynb_checkpoints", "\\.ssh",
                  \"\\.julia", "\\.Trash", "music", "Documents", "Movies", "dist", "ace", "ace-builds", "\\.mplayer",
                  \"\\.ihaskell", "dev", "bundle", "tmp", "Pictures", "\\.store", "env", "Metadata", "weights",
                  \"Library", "downloads", "archive", "Public", "default", "\\.ipython", "*\\.pages",
                  \"\\.cups", "\\.subversion", "security", "\\.sass-cache", "gen", "bootstrap"]
let ignore_exts = ["exe", "so", "dll", "doc", "svg", "mp4", "mp3", "hi", "a", "p_hi", "p_o",  "Xauthority",
                   \"swp", "swo", "DS_store", "docx", "ipynb", "npy", "avi", "jar", "min.js", "htoprc",
                   \"bash_history", "lesshst", "pyg", "tar", "tga", "ttf", "plist", "zcompdump", "julia_history",
                   \"histfile", "haskeline", "log", "zip", "bib", "out", "toc", "ppt", "mat", "sh_history",
                   \"fasd", "floorc", "rnd", "aux", "nb", "xml", "bcf", "lof", "blg", "lot", "jpeg",
                   \"viminfo", "gitconfig", "serverauth*", "nav"]

let g:ctrlp_custom_ignore = {
  \ 'dir': '\v[/]('.join(ignore_dirs, '|').')$',
  \ 'file': '\v\.('.join(ignore_exts, '|').')$',
  \ }
let g:ctrlp_cache_dir = g:home."/.vim/tmp/ctrlp"
map <c-b> :CtrlPLine<CR>
imap <c-b> <ESC><c-/>

Bundle 'tpope/vim-markdown'
Bundle 'petRUShka/vim-opencl'
Bundle 'JuliaLang/julia-vim'
Bundle 'scrooloose/nerdcommenter'

" Syntastic configurations - open error window automatically with size 4
Bundle 'scrooloose/syntastic'
let g:syntastic_auto_loc_list=1
let g:syntastic_loc_list_height=4
let g:syntastic_check_on_open=1
let g:syntastic_python_checker="flake8"
let g:syntastic_always_populate_loc_list=1
let g:syntastic_haskell_checkers=['hdevtools', 'hlint']
let g:syntastic_haskell_ghc_mod_args="-g -fno-warn-name-shadowing -g -fno-warn-orphans -g -fobject-code"
let g:syntastic_haskell_hdevtools_args="-g -fno-warn-name-shadowing -g -fno-warn-orphans -g -fobject-code"
let g:syntastic_tex_checkers=['chktex']
let g:syntastic_tex_chktex_args='-n 1'

map gn :ll<Space>\|<Space>lnext<CR>
map gN :ll<Space>\|<Space>lprev<CR>

" Haskell mode
Bundle 'Twinside/vim-haskellConceal'
Bundle 'bitc/vim-hdevtools'

au FileType haskell nnoremap <buffer> <D-1> :HdevtoolsType<CR>
au FileType haskell nnoremap <buffer> <silent> <D-2> :HdevtoolsClear<CR>

Bundle 'lukerandall/haskellmode-vim'
set shiftwidth=2
Bundle 'dag/vim2hs'
Bundle 'Twinside/vim-haskellFold'
let g:haddock_indexfiledir=g:home."/.vim/resources/haskell/"
let g:haddock_docdir="/home/silver/.cabal/share/doc"
let g:haddock_browser="/usr/bin/firefox"

" Required for vundle "
filetype plugin indent on

" LaTeX stuff "
set grepprg=grep\ -nH\ $*
let g:Tex_DefaultTargetFormat='pdf'
let g:tex_flavor='latex'
let g:Tex_CompileRule_pdf='pdflatex -shell-escape -interaction=nonstopmode $*'
let g:Imap_UsePlaceHolders = 0

if has('macunix')
    let g:Tex_ViewRule_pdf='Skim'
endif

" Recompile LaTeX files every time I save
au! BufWritePost *.tex call Tex_CompileMultipleTimes()
au! BufUnload *.tex !latexclean

" Set shell to be reasonable in GUI vim
if has("gui_running")
    set shell=/usr/local/bin/zsh\ -il
endif

" Tab = Four Spaces "
call TabBehaviour()

" Disable Arrow Keys and Add Useful Mappings
call DisableArrowKeys()

" Traditional search "
call SearchBehaviour()

" Do not use arrow keys for movement "
call DisableArrowKeys()

" Hide annoying files "
call BackupAndSwapFiles()

" Use tag jumping
call SetupTags()

" Syntax and highlighting "
call SyntaxHighlighting()

" Enable code folding "
call CodeFolding()

" Enable autoindent "
call AutoIndent()

" No bell "
set vb t_vb=
autocmd GUIEnter * set visualbell t_vb=

" Custom language settings "
au! BufEnter,BufNewFile,BufRead *.java  so ~/.vim/languages/Java.vim
au! BufEnter,BufNewFile,BufRead *.tex   so ~/.vim/languages/Latex.vim
au! BufEnter,BufNewFile,BufRead *.hs    so ~/.vim/languages/Haskell.vim
au! BufEnter,BufNewFile,BufRead *.py    so ~/.vim/languages/Python.vim
au! BufEnter,BufNewFile,BufRead *.html  so ~/.vim/languages/Html.vim
au! BufEnter,BufNewFile,BufRead *.cl  setf opencl

" Ignore these files with these extensions when auto-completing files "
set wildignore=*.o,*.obj,*.exe,*.jpg,*.gif,*.png,*.class,*.hi,*.pdf,*.pyc,*.jpeg,*.gz,*.cache

" Use shell-like autocompletion "
set wildmode=longest:list

" Have a useful title? "
set title

" Mappings "

" Configure many useful mappings using the space key"
let g:mapleader=' '
map <Leader><Leader> :
map <Leader>w :w<CR>:echo "Written at " . strftime("%c")<CR><ESC>
map <Leader>q :q<CR>
map <Leader>x :wq<CR>
map <Leader>e :e 
map <Leader>s :%s//cg<Left><Left><Left>
vmap <Leader>s :s//cg<Left><Left><Left>
map <Leader>t :SyntasticToggleMode<CR>
map <Leader>i :set invpaste<CR>
map <Leader>v :vs 
map <Leader>g :sp 
vmap <Leader>y "*y

map ' `

noremap <S-u> <C-a>

" Move <C-e> to something else
noremap <C-z> <C-e>
inoremap <C-z> <C-e>


" Heresy
imap <C-e> <ESC>$a
imap <C-a> <ESC>^i
imap <C-k> <ESC>Da

nmap  <C-e>  <ESC>$
nmap  <C-a> <ESC>^
nmap <C-k> D

vmap <C-a> ^
vmap <C-e> $

cmap <C-a> <C-b>
cmap <C-n> <Down>
cmap <C-p> <Up>
cmap <C-r><C-r> <C-r>"

" Tabs "
map <C-t> <ESC>:tabnew 
imap <C-t> <ESC>:tabnew 
map <C-h> <ESC>:tabp<CR>
imap <C-h> <ESC>:tabp<CR>
map <C-l> <ESC>:tabn<CR>
imap <C-l> <ESC>:tabn<CR>

" Always keep a few lines above/below the cursor for context "
set scrolloff=5

command! Reload call VimSetup()

" **********************   End Quick Config   ********************************** "
endfunction


" **************************   Functions   ************************************* "

" Tabs: Expand tabs to four spaces each. "
function! TabBehaviour()
    " Use spaces, not real tabs "
    set expandtab

    " When indenting with cindent, >>, <<, etc, use 4 spaces "
    set shiftwidth=4

    " When hitting tab or backspace, a tab should be 4 spaces "
    set softtabstop=4

    " For consistency, treat even real tabs as 4 spaces "
    set tabstop=4

    " If cursor is at 3 spaces, you press >>, go to 4, not 7 "
    set shiftround
endfunction


" Search: incremental search that isn't stupid "
function! SearchBehaviour()
    " Incremental search "
    set incsearch

    " Ignore case of search strings, unless capitals are included "
    set ignorecase
    set smartcase

    set nohlsearch
endfunction


" Arrow Keys: Disable arrow keys for movement, use hjkl instead"
function! DisableArrowKeys()
    " Normal mode " 
    map <Down> 10k
    map <Up> 10j
    map <Right> 10l
    map <Left> 10h

    " Insert mode "
    imap <Down> <Nop> 
    imap <Up> <Nop>
    imap <Right> <Nop>
    imap <Left> <Nop>
endfunction


" Backup And Swap Files: Keep in ~/.vim/tmp/backup and ~/.vim/tmp, respectively "
function! BackupAndSwapFiles()
    " Make backup files in .vim/tmp/backup "
    set backup
    set backupdir=~/.vim/tmp/backup

    " Put swap files (.swo, .swp) in .vim/tmp "
    set directory=~/.vim/tmp
endfunction

" Setup Tags: Enable ctags and create mappings for jumping around. "
function! SetupTags()
    " ctags file "
    set tags=~/.vim/tmp/tags

    map <C-\> :pop<CR>
    imap <C-\> <ESC>:pop<CR>
endfunction

" Syntax Highlighting: enabled, color-themed, and customized "
function! SyntaxHighlighting()
    " Enable syntax highlighting "
    syntax on

    " Use a colorscheme so that not everything has to be hand-set "
    if has("gui_running")
        source ~/.vim/rdark.vim
    else
        colorscheme darkblue
    endif
endfunction


" Code Folding: allow code folding for functions, etc "
function! CodeFolding()
    " Enable code folding "
    set foldenable

    " C-style folding "
    set foldmethod=marker
    set foldmarker={,}

    " Don't autofold unless we have at least 5 lines "
    set foldminlines=5
endfunction

" Autoindent: enable autoindentation for c and other languages "
function! AutoIndent()
    set smartindent
endfunction

" ************************   End Functions   ************************************ "

" Run the configuration "
if !exists("g:ran_setup")
    call VimSetup()
endif
