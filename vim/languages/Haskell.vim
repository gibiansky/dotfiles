function! haskell#bundles()

endfun

function! haskell#enter()
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
    setlocal noautochdir

    silent! iunmap <buffer> <s-tab>
    imap <S-tab> <ESC><<gi
    set backspace=indent,start

    " Hack for IHaskell
    if getcwd() =~ "/src"
    let args = "-g -fno-warn-name-shadowing -g -fno-warn-orphans -g -fobject-code -g -optP-include -g -optP../dist/build/autogen/cabal_macros.h"
    let g:syntastic_haskell_ghc_mod_args=args
    let g:syntastic_haskell_hdevtools_args=args
    endif
endfun
