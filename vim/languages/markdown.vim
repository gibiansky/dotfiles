function! markdown#bundles()
endfun

function! markdown#enter()
    setf markdown
    setlocal textwidth=100

    augroup markdownsave
        autocmd!
        au InsertCharPre,InsertLeave,CursorHold,CursorHoldI *.md w 
        au InsertCharPre,BufWritePost,InsertLeave,CursorHoldI,CursorHold *.md silent !curl --silent localhost:1337 -H "X-Filename: %"
        set updatetime=300
    augroup END
endfun
