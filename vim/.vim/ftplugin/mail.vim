" complete my mutt aliases
setl omnifunc=muttaliasescomplete#Complete

setl spell

" from vim's ftplugin/mail.vim:
" "many people recommend keeping e-mail messages 72 chars wide"
setl colorcolumn=+0

" sometimes you want to go 78 characters
"setl colorcolumn=+0,78

" formatting options
" t	Automatic formatting of text using textwidth (but not comments)
setl formatoptions+=t

" r	Automatically insert the current comment leader after hitting <Enter>
"	in Insert mode.
setl formatoptions-=r
