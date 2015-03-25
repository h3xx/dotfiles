" FUCK YOU, /usr/share/vim/vim75/indent/php.vim! I don't want your stupid
" formatoptions!
let g:PHP_autoformatcomment = 0
setl fo-=anotw
setl fo+=tcqlr
setl comments=s1:/*,mb:*,ex:*/,://,:#

" Conform to PEAR standards
" Waste space with four spaces instead of a tab
setl sts=4 sw=4 ts=8
