" FUCK YOU, /usr/share/vim/vim75/indent/php.vim! I don't want your stupid
" formatoptions!
" (addendum: not so bad in later versions; still terrible in the version vim
" ships with)
"let g:PHP_autoformatcomment = 0
"setl fo-=anotw
"setl fo+=tcqlr
"setl comments=s1:/*,mb:*,ex:*/,://,:#

setl keywordprg=~/.vim/bin/php_doc

" Syntax check the current buffer when `:make'
setl makeprg=php\ -ln\ % |
setl errorformat=%m\ in\ %f\ on\ line\ %l,%-GErrors\ parsing\ %f,%-G

" Conform to PEAR standards
" Reference: http://pear.php.net/manual/en/standards.indenting.php
setl et sts=4 sw=4 ts=4

" Search ClassName.php when doing `gf'
setl suffixesadd=.php
