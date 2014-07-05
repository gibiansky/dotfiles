syn match dnaLine "^[ AaGgCcTt.,*]*$" contains=dnaA,dnaG,dnaC,dnaT
syn match   dnaA    "[Aa]" contained
syn match   dnaG    "[Gg]" contained
syn match   dnaC    "[Cc]" contained
syn match   dnaT    "[Tt]" contained

hi dnaA ctermfg=1
hi dnaG ctermfg=2
hi dnaC ctermfg=3
hi dnaT ctermfg=5

set nowrap

function! HiColumns()
    let lnum = line(".")
    let line = getline(lnum)
    let next = getline(lnum + 1)
    let len = strlen(line) - 1
    let cols = ""
    let i = 0
    while i <= len
        let c = strpart(line, i, 1)
        let c2 = strpart(next, i, 1)

        let i = i + 1
        if c != c2
            let cols = cols . i . ","
        endif
    endwhile
    let &l:colorcolumn=strpart(cols, 0, strlen(cols) - 1)
endfunction

au! CursorHoldI *.dna call HiColumns()
au! CursorHoldI * if @% == "" | call HiColumns()
set updatetime=200
hi ColorColumn ctermfg=White ctermbg=Black
