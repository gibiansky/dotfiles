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
endfun

function! haskell#leave()
    "silent! NeoCompleteDisable
endfun
