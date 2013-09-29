" Required for Haskell mode
compiler ghc

set makeprg=ghc\ -odir\ tmp\ -hidir\ tmp\ %

set shiftwidth=2
set tabstop=2
set softtabstop=2

map <F2> <ESC>:make<CR>
imap <F2> <ESC><F2>
map <F3> <ESC>:!./Main<Space>
imap <F3> <ESC><F3>

set foldmethod=marker
set foldmarker={,}

nnoremap <buffer> <F1> :HdevtoolsType<CR>
nnoremap <buffer> <silent> <F2> :HdevtoolsClear<CR>
