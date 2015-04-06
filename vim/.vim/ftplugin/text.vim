" formatting options
" n	Recognize numbered lists when formatting.
" a	Automatic formatting of paragraphs (every time the text is modified).
"	(addendum: this is really damn annoying)
setl fo+=n

" c	Auto-wrap comments using textwidth, inserting the current comment
"	leader automatically.
"	(text doesn't have comments)
setl fo-=c

" list regex
" default: "^\s*\d\+[\]:.)}\t ]\s*"
" format bulleted lists ([*+-]\s) like numbered lists
setl flp=^\\s*\\(\\d\\\|*\\\|+\\\|-\\)\\+[\\]:.)}\\t\ ]\\s*
