function! python#bundles()
    Plugin 'hynek/vim-python-pep8-indent'
endfunction

function! python#enter()
    setf python
    set nosmartindent
    set foldmethod=indent

    setlocal textwidth=79
    setlocal colorcolumn=+1
endfunction
