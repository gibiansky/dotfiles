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


" Vundle
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'

" Allow us to put remote plugins in ~/.vim/rplugin 
set rtp+=~/.vim
if has("nvim")
    " Set up :terminal mappings
    tmap <Esc><Esc> <C-\><C-n>
endif

" Check if we're running in tmux, and if so, enable tmux-specific navigation
let g:tmux = system("printf $TMUX")
if len(g:tmux) != 0
    let g:tmux_navigator_no_mappings = 1

    nnoremap <silent> <C-w>h :TmuxNavigateLeft<cr>
    nnoremap <silent> <C-w>j :TmuxNavigateDown<cr>
    nnoremap <silent> <C-w>k :TmuxNavigateUp<cr>
    nnoremap <silent> <C-w>l :TmuxNavigateRight<cr>
    nnoremap <silent> <C-w><C-w> :TmuxNavigatePrevious<cr>

    Plugin 'christoomey/vim-tmux-navigator'
endif

" Load general plugins
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'
Plugin 'Raimondi/delimitMate'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-repeat'
Plugin 'tomtom/tlib_vim'
Plugin 'godlygeek/tabular'

Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
let g:UltiSnipsExpandTrigger = '<c-j>'

Plugin 'Valloric/YouCompleteMe'
let g:ycm_allow_changing_updatetime = 0
let g:ycm_confirm_extra_conf=0
" let g:ycm_semantic_triggers = {'haskell' : ['.', '(']}
let g:ycm_filetype_blacklist = {'haskell': 1}
let g:ycm_autoclose_preview_window_after_completion=1

call CtrlPSetup()
call SyntasticSetup()

Plugin 'derekwyatt/vim-scala'

" Language plugins
let supported_languages = split(globpath('~/.vim/languages', '*'), '\n')
call map(supported_languages, 'split(v:val, "/")[-1]')
call map(supported_languages, 'split(v:val, "\\.")[0]')
for language in supported_languages
    " Include bundles for languages
    exe 'source ~/.vim/languages/' . language . '.vim'
    if exists('*' . language . '#bundles')
        exe 'call ' . language . '#bundles()'
    endif
endfor

" Detect whether we're in tmux
" Plugin 'christoomey/vim-tmux-navigator'
" if len($TMUX) != 0
"     let g:tmux_navigator_no_mappings = 1
"     nnoremap <silent> <C-w>h :TmuxNavigateLeft<cr>
"     nnoremap <silent> <C-w>j :TmuxNavigateDown<cr>
"     nnoremap <silent> <C-w>k :TmuxNavigateUp<cr>
"     nnoremap <silent> <C-w>l :TmuxNavigateRight<cr>
"     nnoremap <silent> <C-\> :TmuxNavigatePrevious<cr>
" endif

" Required for vundle
call vundle#end()
filetype plugin indent on

" Set shell to be reasonable in GUI vim
if has("gui_running")
    set shell=/usr/local/bin/zsh\ -il
endif

" Tab = Four Spaces "
call TabBehaviour()

" Multiply Arrow Keys by 10
call ArrowKeys()

" Traditional search "
call SearchBehaviour()

" Hide annoying files "
call BackupAndSwapFiles()

" Use tag jumping
call SetupTags()

" Syntax and highlighting "
call SyntaxHighlighting()

" Enable code folding "
call CodeFolding()

" No bell "
set vb t_vb=
autocmd GUIEnter * set visualbell t_vb=

" Language autodetect
augroup filetypedetect
    let language_extensions = {
        \ "haskell":   "hs",
        \ "latex":     "tex",
        \ "python":    "py",
        \ "asciidoc":  "adoc",
        \ "opencl":    "cl",
        \ "cuda":      "cu",
        \ "rust":      "rs"
        \ }
    for [lang, ext] in items(language_extensions)
        if exists('*' . lang . '#enter')
            exe 'au! BufEnter,BufNewFile *.' . ext . ' call ' . lang . '#enter()'
        endif
        if exists('*' . lang . '#leave')
            exe 'au! BufLeave,BufUnload,BufDelete *.' . ext . ' call ' . lang . '#leave()'
        endif
    endfor
augroup END

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
map <Leader>! :q!<CR>
map <Leader>x :wq<CR>
map <Leader>e :e 
map <Leader>s :%s//cg<Left><Left><Left>
vmap <Leader>s :s//cg<Left><Left><Left>
map <Leader>t :SyntasticToggleMode<CR>
map <Leader>i :set invpaste<CR>
map <Leader>v :vs 
map <Leader>g :sp 
vmap <Leader>y "*y

" Switch directories to current file instead of autochdir
map <Leader>d :lcd %:p:h<CR>

map <Leader><Right> :vertical resize +5<CR>
map <Leader><Left> :vertical resize -5<CR>
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
" NeoVim is really dumb, doing a remapping in iTerm
if has("nvim")
  map <Char-0x89> <ESC>:tabp<CR>
  imap <Char-0x89> <ESC>:tabp<CR>
else
  map <C-h> <ESC>:tabp<CR>
  imap <C-h> <ESC>:tabp<CR>
endif
map <C-t> <ESC>:tabnew 
imap <C-t> <ESC>:tabnew 
map <C-l> <ESC>:tabn<CR>
imap <C-l> <ESC>:tabn<CR>


" Always keep a few lines above/below the cursor for context "
set scrolloff=5

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

    Plugin 'freeo/vim-kalisi'

    " Use a colorscheme so that not everything has to be hand-set "
    if has("gui_running")
        colorscheme rdark
    elseif has("nvim")
        set background=dark
        colorscheme kalisi
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

" Syntastic configurations
function! SyntasticSetup()
    Plugin 'scrooloose/syntastic'
    let g:syntastic_auto_loc_list=1 " open error window automatically with size 4
    let g:syntastic_loc_list_height=4
    let g:syntastic_check_on_open=1
    let g:syntastic_python_checkers=["pyflakes", "pep8", "pylint"]
    let g:syntastic_always_populate_loc_list=1

    map gn :ll<Space>\|<Space>lnext<CR>
    map gN :ll<Space>\|<Space>lprev<CR>
endfunction

" Ctrl-P file finder
function! CtrlPSetup()
    Plugin 'kien/ctrlp.vim'

    let g:ctrlp_extensions = ['line', 'mixed']
    let g:ctrlp_map = '<c-n>'
    let g:ctrlp_cmd = 'CtrlP ' . g:home
    let g:ctrlp_working_path_mode=0
    let g:ctrlp_show_hidden=1
    let g:ctrlp_prompt_mappings = {
        \ 'AcceptSelection("h")': ['<c-g>'],
        \ }
    " Don't regenerate the cache every time
    let g:ctrlp_clear_cache_on_exit = 0

    " Places for Ctrl-P to ignore
    let ignore_dirs = ["\\.git", "\\.hg", "\\.svn", "\\.cache", "\\.ghc", "\\.gem", "\\.shelly", "\\.text", "\\.theano",
                    \"\\.cabal", "\\.ipynb_checkpoints", "stuff", "\\.matlab", "\\.ipynb_checkpoints", "\\.ssh", "\\.antigen",
                    \"\\.gradle", "\\.asy", "\\.lein", "\\.boot2docker", "\\.m2", "\\.vagrant.d", "\\.android", "\\.idea",
                    \"\\.julia", "\\.Trash", "\\.stack", "music", "Documents", "Movies", "dist", "ace", "ace-builds", "\\.mplayer",
                    \"\\.ihaskell", "dev", "bundle", "tmp", "Pictures", "\\.store", "env", "Metadata", "weights", "\\.cabal-sandbox",
                    \"Library", "downloads", "archive", "Public", "default", "\\.ipython", "*\\.pages", "Applications", "old", "ghc",
                    \"\\.cups", "\\.subversion", "security", "\\.sass-cache", "gen", "bootstrap", "\\.local", "\\.ivy2", "nofib",
                    \"\\.cargo", "\\.stack-work", "bin", "\\.npm", "\\.config"]
    let ignore_exts = ["exe", "so", "dll", "doc", "svg", "mp4", "mp3", "hi", "a", "p_hi", "p_o",  "Xauthority",
                    \"swp", "swo", "DS_store", "docx", "ipynb", "npy", "avi", "jar", "min.js", "htoprc",
                    \"bash_history", "lesshst", "pyg", "tar", "tga", "ttf", "plist", "zcompdump", "julia_history",
                    \"histfile", "haskeline", "log", "zip", "bib", "out", "toc", "ppt", "mat", "sh_history",
                    \"arcrc", "pearrc", "nviminfo", "ico", "cdr", "iml", "iso", "serverauth.2686", "clang_complete", "xcf", 
                    \"fasd", "floorc", "rnd", "aux", "nb", "xml", "bcf", "lof", "blg", "lot", "jpeg",
                    \"viminfo", "gitconfig", "serverauth*", "nav"]

    let g:ctrlp_custom_ignore = {
    \ 'dir': '\v[/]('.join(ignore_dirs, '|').')$',
    \ 'file': '\v\.('.join(ignore_exts, '|').')$',
    \ }
    let g:ctrlp_cache_dir = g:home."/.vim/tmp/ctrlp"
    map <c-b> :CtrlPLine<CR>
    imap <c-b> <ESC><c-/>
endfunction

" ************************   End Functions   ************************************ "

" Run the configuration "
if !exists("g:ran_setup")
    call VimSetup()
endif
