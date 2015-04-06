" Only do this part when compiled with support for autocommands.
if has("autocmd")
  autocmd Filetype java setlocal omnifunc=javacomplete#Complete
endif
setlocal completefunc=javacomplete#CompleteParamsInfo
inoremap <buffer> <C-X><C-U> <C-X><C-U><C-P>
inoremap <buffer> <C-S-Space> <C-X><C-U><C-P>
