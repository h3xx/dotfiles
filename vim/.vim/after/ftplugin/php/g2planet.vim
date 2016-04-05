" G2Planet customizations

setl path=.
setl path+=..
setl path+=../..
setl path+=../templates
setl path+=../utility
setl path+=../page
setl path+=../eclib/page
setl path+=../eclib/database
setl path+=../eclib/templates
setl path+=../../eclib/page
setl path+=../../eclib/database
setl path+=../../eclib/templates
setl path+=../emaxlib/page
setl path+=../emaxlib/database
setl path+=../../emaxlib/page
setl path+=../../emaxlib/database
setl path+=../eventlib/database
setl path+=../eventlib/page
setl path+=../../eventlib/database
setl path+=../../eventlib/page
" current dir
setl path+=

" open unit test file
nnoremap <buffer> g<C-f> :tabe ../tests/<C-r>=expand("%:t:r")<CR>Test.php<CR>
" open mock dataset
nnoremap <buffer> g<C-d> :silent! Mkdir <C-r>=expand("%:t:r")<CR>Data<CR>:tabe <C-r>=expand("%:t:r")<CR>Data/dataset.yaml<CR>

" hopefully this will be less laggy
"setl fdm=indent
