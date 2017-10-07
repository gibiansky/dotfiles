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

" Enable autoindent "
set smartindent

" No bell "
set vb t_vb=
autocmd GUIEnter * set visualbell t_vb=

set backspace=indent,start

" Give me a reasonable history
set history=1000

" Not compatible with Ex.
" Required for Vundle.
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

" Ignore these files with these extensions when auto-completing files "
set wildignore=*.o,*.obj,*.exe,*.jpg,*.gif,*.png,*.class,*.hi,*.pdf,*.pyc,*.jpeg,*.gz,*.cache

" Use shell-like autocompletion "
set wildmode=longest:list

" Have a useful title? "
set title

" Always keep a few lines above/below the cursor for context "
set scrolloff=3

" Vundle
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'

" Load general plugins
Plugin 'Raimondi/delimitMate'   " Autocompletion for brackets
Plugin 'tpope/vim-surround'     " Text object for brackets
Plugin 'tpope/vim-repeat'       " Use . with vim-surround
Plugin 'tomtom/tlib_vim'
Plugin 'godlygeek/tabular'      " Tabular formatting with :Tab

Plugin 'SirVer/ultisnips'       " Vim snippets
Plugin 'honza/vim-snippets'
let g:UltiSnipsExpandTrigger = '<c-j>'

Plugin 'dracula/vim' " My color scheme of choice

" Asynchronous linting for many languages
Plugin 'w0rp/ale'

" Python vundle plugins
Plugin 'Vimjas/vim-python-pep8-indent'

" Required for vundle
call vundle#end()
filetype plugin indent on

" Tab = Four Spaces "
call TabBehaviour()

" Multiply Arrow Keys by 10
call ArrowKeys()

" Traditional search "
call SearchBehaviour()

" Hide annoying files "
call BackupAndSwapFiles()

" Syntax and highlighting "
call SyntaxHighlighting()

" Enable code folding "
call CodeFolding()

" All sorts of miscellaneous custom mappings
call MyMappings()

" Language configurations and autocommands
call LanguageConfigs()

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


" Arrow Keys: Disable arrow keys for normal movement, use hjkl instead"
function! ArrowKeys()
    " Normal mode " 
    map <Down> 10j
    map <Up> 10k
    map <Right> 10l
    map <Left> 10h

    " Insert mode "
    imap <Down> <ESC><Down>
    imap <Up> <ESC><Up>
    imap <Right> <ESC><Right>
    imap <Left> <ESC><Left>
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

    " Dark background
    set background=dark
    colorscheme dracula
endfunction


" Code Folding: allow code folding for functions, etc "
function! CodeFolding()
    " Enable code folding "
    set foldenable

    " Don't autofold unless we have at least 5 lines "
    set foldminlines=3
endfunction

" Keyboard Mappings: Custom mappings I use often
function! MyMappings()
    " Configure many useful mappings using the space key"
    let g:mapleader=' '
    map <Leader><Leader> :
    map <Leader>w :w<CR>:echo "Written at " . strftime("%c")<CR><ESC>
    map <Leader>q :q<CR>
    map <Leader>! :q!<CR>
    map <Leader>x :wq<CR>
    map <Leader>e :e 
    map <Leader>s :%s//cg<Left><Left><Left>
    vmap <Leader>s :s//cg<Left><Left><Left>
    map <Leader>i :set invpaste<CR>
    map <Leader>v :vs 
    map <Leader>g :sp 
    vmap <Leader>y "*y
    
    " Switch directories to current file instead of autochdir
    map <Leader>d :lcd %:p:h<CR>
    
    map <Leader><Right> :vertical resize -5<CR>
    map <Leader><Left> :vertical resize +5<CR>
    map <Leader><Down> :resize +5<CR>
    map <Leader><Up> :resize -5<CR>
    
    map ' `
    
    noremap <S-u> <C-a>
    
    " Move <C-e> to something else
    noremap <C-z> <C-e>
    inoremap <C-z> <C-e>
    
    " Use C-y to insert a whole word
    inoremap <expr> <c-y> matchstr(getline(line('.')-1), '\%' . virtcol('.') . 'v\%(\k\+\\|.\)')
    
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
    map <C-h> <ESC>:tabp<CR>
    imap <C-h> <ESC>:tabp<CR>
    map <C-t> <ESC>:tabnew 
    imap <C-t> <ESC>:tabnew 
    map <C-l> <ESC>:tabn<CR>
    imap <C-l> <ESC>:tabn<CR>
endfunction

function! LanguageConfigs()
    autocmd FileType python     set textwidth=79
    autocmd FileType python     set colorcolumn=+1
    autocmd FileType python     set nosmartindent
endfunction

" ************************   End Functions   ************************************ "

" Run the configuration "
if !exists("g:ran_setup")
    call VimSetup()
endif
