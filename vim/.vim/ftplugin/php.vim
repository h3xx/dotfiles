" FUCK YOU, /usr/share/vim/vim75/indent/php.vim! I don't want your stupid
" formatoptions!
let g:PHP_autoformatcomment = 0
setl fo-=anotw
setl fo+=tcqlr
setl comments=s1:/*,mb:*,ex:*/,://,:#
setl keywordprg=~/.vim/bin/php_doc

" syntax check the current buffer when `:make'
setl makeprg=php\ -ln\ % |
setl errorformat=%m\ in\ %f\ on\ line\ %l,%-GErrors\ parsing\ %f,%-G

" search ClassName.php when doing `gf'
setl suffixesadd=.php

" hopefully this will be less laggy
"setl fdm=indent
