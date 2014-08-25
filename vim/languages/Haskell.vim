function! haskell#bundles()
    Plugin 'godlygeek/tabular'
    Plugin 'travitch/hasksyn'

    Plugin 'Shougo/neocomplete.vim'
    let g:neocomplete#enable_at_startup = 1

    Plugin 'eagletmt/neco-ghc'
    let  g:necoghc_enable_detailed_browse = 1
    setlocal omnifunc=necoghc#omnifunc
endfun

function! haskell#enter()
    setf haskell

    " Use two-space indentation
    setlocal shiftwidth=2
    setlocal tabstop=2
    setlocal softtabstop=2

    " Create tabularize mappings for aligning type signatures
    AddTabularPattern! hs_type_sig / \?\(->\|::\|=>\)/l0r1
    inoremap -> -><ESC>:Tab hs_type_sig<CR>A 
    inoremap => =><ESC>:Tab hs_type_sig<CR>A 

    " ...for aligning comments.
    AddTabularPattern! hs_comment / \?--/l0r1
    inoremap -- --<ESC>:Tab hs_comment<CR>A 

    " ...for aligning comments.
    AddTabularPattern! hs_comment / \?--/l0r1
    inoremap -- --<ESC>:Tab hs_comment<CR>A 
endfun
