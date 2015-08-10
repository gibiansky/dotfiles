function! asciidoc#bundles()
    Plugin 'dagwieers/asciidoc-vim'
endfun

function! asciidoc#enter()
    setf asciidoc
    setlocal textwidth=100

    augroup asciidocsave
        autocmd!
        au BufWritePost *.adoc !asciidoctor -r ./fix-pygments.rb -r ./fix-double-colon.rb -r ./undo-replacements-extension.rb -a data-uri %
    augroup END
endfun
