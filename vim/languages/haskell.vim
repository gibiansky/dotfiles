function! haskell#bundles()
    Plugin 'travitch/hasksyn'

    let g:syntastic_haskell_checkers=["hdevtools", "hlint"]
    Plugin 'kana/vim-textobj-user'
    Plugin 'gibiansky/vim-textobj-haskell'
    Plugin 'bitc/vim-hdevtools'
endfun

function! FormatHaskell()
    if !empty(v:char)
        return 1
    else
        let l:filter = "hindent --style gibiansky"
        let l:command = v:lnum.','.(v:lnum+v:count-1).'!'.l:filter
        execute l:command
    endif
endfunction

function! haskell#enter()
    setf haskell
    setlocal softtabstop=2

    nnoremap <buffer> <silent> <Leader>h :HdevtoolsType<CR>
    nnoremap <buffer> <silent> <Leader>c :HdevtoolsClear<CR>

    setlocal formatexpr=FormatHaskell()
    nnoremap <buffer> <silent> <Leader>r mp:normal vahgq<CR>'p

    " Use two-space indentation
    setlocal shiftwidth=2
    setlocal tabstop=2
    setlocal softtabstop=2


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
    "silent! NeoCompleteDisable
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
