function! haskell#bundles()
    Plugin 'godlygeek/tabular'
    Plugin 'travitch/hasksyn'
    Plugin 'Shougo/neocomplete.vim'
    Plugin 'eagletmt/neco-ghc'
endfun

function! haskell#enter()
    setf haskell

    " Autocompletion
    NeoCompleteEnable
    let  g:necoghc_enable_detailed_browse = 1
    setlocal omnifunc=necoghc#omnifunc

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

    " Configuration for syntastic
    let g:syntastic_haskell_checkers=['ghc_mod', 'hlint']

    let ghc_args = ["fno-warn-name-shadowing", "fno-warn-orphans", "fobject-code", "fno-warn-type-defaults"]
    let sandbox = s:get_cabal_sandbox()
    if len(sandbox) != 0
        let package_db = split(globpath(sandbox, "*-packages.conf.d"), '\n')[0]
        call add(ghc_args, 'package-db=' . package_db)
    endif

    call map(ghc_args, '"-g -" . v:val')
    let ghc_args_string = join(ghc_args, ' ')

    let g:syntastic_haskell_ghc_mod_args=ghc_args_string
    let g:syntastic_haskell_hdevtools_args=ghc_args_string
endfun

function! haskell#leave()
    NeoCompleteDisable
endfun

function! s:get_cabal_sandbox()
    if filereadable('cabal.sandbox.config')
        let l:output = system('cat cabal.sandbox.config | grep local-repo')
        let l:dir = matchstr(substitute(l:output, '\n', ' ', 'g'), 'local-repo: \zs\S\+\ze\/packages')
        return l:dir
    else
        return ''
    endif
endfunction
