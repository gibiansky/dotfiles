function! python#bundles()
    Plugin 'hynek/vim-python-pep8-indent'
endfunction

function! python#enter()
    setf python
    set nosmartindent
    set foldmethod=indent

    setlocal textwidth=79
    setlocal colorcolumn=+1

    if filereadable(".pylintrc")
        let g:syntastic_python_pylint_args = '--rcfile=.pylintrc' 
    else
        let g:syntastic_python_pylint_args = '' 
    endif
    if filereadable(".flake8rc")
        let g:syntastic_python_flake8_args = '--config=.flake8rc' 
    else
        let g:syntastic_python_flake8_args = '' 
    endif
endfunction
