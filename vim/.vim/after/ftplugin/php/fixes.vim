" Fix for vim 8.2 and before to make vim-commentary work correctly (also just
" a good idea to include general)
" Note: The reason this is here instead of in regular ftplugin is because
" apparently the system-wide ftplugin/php.vim sets this to "/*%s*/"
setl cms=//\ %s
