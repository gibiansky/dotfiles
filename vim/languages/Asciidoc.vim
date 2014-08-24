function! asciidoc#bundles()
endfun

function! asciidoc#enter()
    set syntax=asciidoc
    set textwidth=100

    au BufWritePost *.adoc !asciidoctor -r ./fix-pygments.rb -r ./fix-double-colon.rb -r ./undo-replacements-extension.rb -a data-uri %
endfun
