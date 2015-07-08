" formatting options
" n	Recognize numbered lists when formatting.
" t	Automatic formatting of text using textwidth (but not comments)
" a	Automatic formatting of paragraphs (every time the text is modified).
"	(addendum: this is really damn annoying)
setl formatoptions+=nt

" c	Auto-wrap comments using textwidth, inserting the current comment
"	leader automatically.
"	(text doesn't have comments)
" r	Automatically insert the current comment leader after hitting <Enter>
"	in Insert mode.
setl formatoptions-=c formatoptions-=r

setl spell

" list regex
" default: "^\s*\d\+[\]:.)}\t ]\s*"
" format bulleted lists ([*+-]\s) like numbered lists
setl formatlistpat=^\\s*\\(\\d\\\|*\\\|+\\\|-\\)\\+[\\]:.)}\\t\ ]\\s*
