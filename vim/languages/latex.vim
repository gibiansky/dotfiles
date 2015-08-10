function! latex#bundles()
    let g:Tex_Leader = '`tex'
    let g:Tex_SmartKeyDot = 0
    Plugin 'jcf/vim-latex'

    Plugin 'gibiansky/vim-latex-objects'
endfun

function! latex#enter()
    setf tex
    set spell
    set foldmethod=marker
    set foldmarker=\\begin,\\end
    set foldminlines=2
    set textwidth=100
    set formatoptions+=b
    let g:Tex_UseMakefile=0

    " Define a function to do echo wordcount
    function! WC()
        let filename = expand("%")
        let cmd = "detex " . filename . " | wc -w | tr -d '[:space:]'"
        let result = system(cmd)
        echo result . " words"
    endfunction

    command! WC call WC()

    call IMAP('()', '()', 'tex')
    call IMAP('{}', '{}', 'tex')
    call IMAP('[]', '[]', 'tex')
    call IMAP('::', '::', 'tex')
    call IMAP('{{', '{{', 'tex')
    call IMAP('((', '((', 'tex')
    call IMAP('[[', '[[', 'tex')
    call IMAP('$$', '$$', 'tex')
    call IMAP('==', '==', 'tex')


    set conceallevel=2
    hi! link Conceal Operator

    " LaTeX stuff "
    set grepprg=grep\ -nH\ $*
    let g:tex_flavor='latex'
    let g:Tex_DefaultTargetFormat='pdf'
    let g:Tex_CompileRule_pdf='pdflatex -shell-escape -interaction=nonstopmode $*'
    let g:Imap_UsePlaceHolders = 0
    let g:Tex_ViewRuleComplete_pdf='/usr/bin/open -a Skim $*.pdf'

    " Recompile LaTeX files every time I save
    au! BufWritePost *.tex call Tex_CompileMultipleTimes()
    au! BufUnload *.tex !latexclean
endfun
