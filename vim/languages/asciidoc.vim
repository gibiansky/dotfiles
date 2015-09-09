function! asciidoc#bundles()
    Plugin 'dagwieers/asciidoc-vim'
endfun

function! asciidoc#enter()
    setf asciidoc
    setlocal textwidth=100

    augroup asciidocsave
        autocmd!
        au BufWritePost *.adoc !asciidoctor -r ~/code/old/hefty-haskell/fix-pygments.rb -r ~/code/old/hefty-haskell/fix-double-colon.rb -r ~/code/old/hefty-haskell/undo-replacements-extension.rb -a data-uri %
    augroup END
endfun
