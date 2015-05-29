" FUCK YOU, /usr/share/vim/vim75/indent/php.vim! I don't want your stupid
" formatoptions!
" (addendum: not so bad in later versions; still terrible in the version vim
" ships with)
"let g:PHP_autoformatcomment = 0
"setl fo-=anotw
"setl fo+=tcqlr
"setl comments=s1:/*,mb:*,ex:*/,://,:#

" conform to PEAR standards
" reference: http://pear.php.net/manual/en/standards.indenting.php
setl ts=4 sw=4 sts=4 et

setl keywordprg=~/.vim/bin/php_doc

" syntax check the current buffer when `:make'
setl makeprg=php\ -ln\ % |
setl errorformat=%m\ in\ %f\ on\ line\ %l,%-GErrors\ parsing\ %f,%-G

" search ClassName.php when doing `gf'
setl suffixesadd=.php
