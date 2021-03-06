nnoremap <Leader>t :make test<CR>
nnoremap <Leader>d :make doc<CR>
nnoremap <Leader>m :make build<CR>

" recognize test error locations
let &errorformat="### Failure in %f:%l: %m," . &errorformat

" highlight haskell blocks in markdown files
let g:markdown_fenced_languages=['haskell']
