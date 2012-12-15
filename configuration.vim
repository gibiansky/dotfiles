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

" Not compatible with Ex "
set nocompatible

" Remove menu bar
set guioptions-=m

" Remove toolbar
set guioptions-=T

" Vundle "
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'

" Include bundles "
let g:indexer_lookForProjectDir=0
let g:indexer_indexerListFilename=g:home."/.vim/indexer.list"
let g:indexer_tagsDirname=g:home."/.vim/tags"
Bundle 'shemerey/vim-indexer'

Bundle 'Raimondi/delimitMate'

Bundle 'JuliaLang/julia-vim'

" Required for vundle "
filetype plugin indent on

" LaTeX stuff "
set grepprg=grep\ -nH\ $*
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
au! BufNewFile,BufRead *.java so ~/.vim/languages/Java.vim
au! BufNewFile,BufRead *.tex so ~/.vim/languages/Latex.vim
au! BufNewFile,BufRead *.hs so ~/.vim/languages/Haskell.vim
let g:Tex_DefaultTargetFormat='pdf'

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
map  <C-e>  <ESC>$
map  <C-a> <ESC>^
map <C-k> D
imap <C-k> <ESC>Da

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

exec("source " . g:home . "/.vim/current-projects.vim")

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

" Syntax Highlighting: enabled, color-themed, and customized "
function! SyntaxHighlighting()
    " Enable syntax highlighting "
    syntax on

    " Use a colorscheme so that not everything has to be hand-set "
    " Source: vimcolorschemetest.googlecode.com/svn/colors/af.vim
    source ~/.vim/colorscheme.vim
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
