set spell
set foldmethod=indent
set foldminlines=2
set textwidth=100
set formatoptions+=b

" Define a function to do echo wordcount
function! WC()
    let filename = expand("%")
    let cmd = "detex " . filename . " | wc -w | tr -d '[:space:]'"
    let result = system(cmd)
    echo result . " words"
endfunction

command! WC call WC()