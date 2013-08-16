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

" Line numbers "
set number

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

" Include bundles "
Bundle 'Raimondi/delimitMate'
Bundle 'jnwhiteh/vim-golang'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-repeat'

Bundle 'hynek/vim-python-pep8-indent'
Bundle 'gaving/vim-textobj-argument'
Bundle 'kchmck/vim-coffee-script'

Bundle 'Floobits/floobits-vim'
Bundle "MarcWeber/vim-addon-mw-utils"
Bundle "tomtom/tlib_vim"
Bundle "garbas/vim-snipmate"
Bundle 'honza/vim-snippets'
" Ctrl-P file finder
Bundle 'kien/ctrlp.vim'
let g:ctrlp_extensions = ['line', 'mixed']
let g:ctrlp_map = '<c-n>'
let g:ctrlp_cmd = 'CtrlPMixed'
map <c-b> :CtrlPLine<CR>
imap <c-b> <ESC><c-/>

let g:ctrlp_prompt_mappings = {
    \ 'AcceptSelection("h")': ['<c-g>'],
    \ }

Bundle 'tpope/vim-markdown'

" Syntastic configurations - open error window automatically with size 4
Bundle 'Syntastic'
let g:syntastic_auto_loc_list=1
let g:syntastic_loc_list_height=4
let g:syntastic_check_on_open=1
let g:syntastic_python_checker="flake8"
let g:syntastic_always_populate_loc_list=1

map gn :ll<Space>\|<Space>lnext<CR>
map gN :ll<Space>\|<Space>lprev<CR>

" Haskell mode
Bundle 'Haskell-Conceal'
Bundle 'indenthaskell.vim'
Bundle 'bitc/vim-hdevtools'
Bundle 'lukerandall/haskellmode-vim'
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
au! BufEnter,BufNewFile,BufRead *.java so ~/.vim/languages/Java.vim
"au! BufEnter,BufNewFile,BufRead *.tex so ~/.vim/languages/Latex.vim
au! BufEnter,BufNewFile,BufRead *.hs so ~/.vim/languages/Haskell.vim
au! BufEnter,BufNewFile,BufRead *.py so ~/.vim/languages/Python.vim
au! BufEnter,BufNewFile,BufRead *.html so ~/.vim/languages/Html.vim

" Recompile LaTeX files every time I save
au! BufWritePost *.tex call Tex_CompileMultipleTimes()
au! BufUnload *.tex !latexclean

" Ignore these files with these extensions when auto-completing files "
set wildignore=*.o,*.obj,*.exe,*.jpg,*.gif,*.png,*.class,*.hi

" Use shell-like autocompletion "
set wildmode=longest:list

" Mappings "

" Press space to enter ex command mode "
map <Space> :
imap <Nop> <ESC>hli

map ' `

noremap <S-u> <C-a>

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
    map <Down> <Nop>
    map <Up> <Nop>
    map <Right> <Nop>
    map <Left> <Nop>

    " Insert mode "
    imap <Down> <Nop> 
    imap <Up> <Nop>
    imap <Right> <Nop>
    imap <Left> <Nop>

    map <S-j> 10j
    map <S-k> 10k
    map <S-h> 10h
    map <S-l> 10l
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
