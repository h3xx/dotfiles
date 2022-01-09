" Use [[, ]] to jump between files
let s:file = '^---'
exe 'nno <buffer> <silent> [[ ?' . s:file . '?<CR>:noh<CR>'
exe 'nno <buffer> <silent> ]] /' . s:file . '/<CR>:noh<CR>'
exe 'ono <buffer> <silent> [[ ?' . s:file . '?<CR>:noh<CR>'
exe 'ono <buffer> <silent> ]] /' . s:file . '/<CR>:noh<CR>'
" Use [m, ]m to jump between hunks
let s:hunk = '^@@'
exe 'nno <buffer> <silent> [m ?' . s:hunk . '?<CR>:noh<CR>'
exe 'nno <buffer> <silent> ]m /' . s:hunk . '/<CR>:noh<CR>'
exe 'ono <buffer> <silent> [m ?' . s:hunk . '?<CR>:noh<CR>'
exe 'ono <buffer> <silent> ]m /' . s:hunk . '/<CR>:noh<CR>'
