" Vim indent file
" Language:	PHP
" Author:	Miles Lott <milos@groupwhere.org>
" URL:		http://www.groupwhere.org/php.vim
" Last Change:	2007 February 18
" Version:	1.2
" Notes:  Close all switches with default:\nbreak; and it will look better.
"         Also, open and close brackets should be alone on a line.
"         This is my preference, and the only way this will look nice.
"         Try an older version if you care less about the formatting of
"         switch/case.  It is nearly perfect for anyone regardless of your
"         stance on brackets.  Also note that we do not attempt to format html
"         code.
"
" Changes: 1.2 - Found syntax error in renaming of variable after 0.7 which
"            broke the formatting of switch/case
"          1.1 - Sameday change/fix to skip lines commented by # also
"          1.0 - Sameday change/fix to skip lines commented by // (Don't format other code
"            if in // comment section
"          0.9 - Sameday bugfix for certain commenting styles, e.g. closing with /**/
"          0.8 - Borrowed methods from current dist of php.vim for automatic formatting of
"            comments (http://www.2072productions.com/?to=phpindent.txt)
"          0.7 - fix for /* comment */ indentation from Devin Weaver <devin@tritarget.com>
"          0.6 - fix indentation for closing bracket (patch from ITLab at MUSC - http://www.itlab.musc.edu/)
"          0.5 - fix duplicate indent on open tag, and empty bracketed statements.
"          0.4 - Fixes for closing php tag, switch statement closure, and php_indent_shortopentags
"            option from Steffen Bruentjen <vim@kontraphon.de>
"
" Options: php_noindent_switch=1 -- do not try to indent switch/case statements or comments (version 0.1 behavior)
"          php_indent_shortopentags=1 -- indent after short php open tags, too
"          php_no_autocomment=1  -- do not automatically format comment sections

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
	finish
endif
let b:did_indent = 1
let b:optionsset = 0

if exists("php_no_autocomment")
	let b:php_no_autocomment = php_no_autocomment
else
	let b:php_no_autocomment = 1
endif

setlocal indentexpr=GetPhpIndent()
"setlocal indentkeys+=0=,0),=EO
setlocal indentkeys+=0=,0),=EO,=>

" Only define the function once.
if exists("*GetPhpIndent")
	finish
endif

" Handle option(s)
if exists("php_noindent_switch")
	let b:php_noindent_switch=1
endif

let s:autorestoptions = 0
if ! s:autorestoptions
	au BufWinEnter,Syntax	*.php,*.php3,*.php4,*.php5	call ResetOptions()
	let s:autorestoptions = 1
endif

function! ResetOptions()
	if ! b:optionsset
		if b:php_no_autocomment
			setlocal comments=s1:/*,mb:*,ex:*/,://,:#
			setlocal formatoptions-=t
			setlocal formatoptions+=q
			setlocal formatoptions+=r
			setlocal formatoptions+=o
			setlocal formatoptions+=w
			setlocal formatoptions+=c
			setlocal formatoptions+=b
		endif
		let b:optionsset = 1
	endif
endfunc

function GetPhpIndent()
	" Find a non-blank line above the current line.
	let lnum = prevnonblank(v:lnum - 1)
	" Hit the start of the file, use zero indent.
	if lnum == 0
		return 0
	endif
	let line = getline(lnum)    " last line
	let lindent = v:(lnum)
	let cline = getline(v:lnum) " current line
	let pline = getline(lnum - 1) " previous to last line
	let ind = indent(lnum)

	" Indent after php open tag
	if line =~ '<?php'
		let ind = ind + &sw
	elseif exists('g:php_indent_shortopentags')
		" indent after short open tag
		if line =~ '<?'
			let ind = ind + &sw
		endif
	endif
	" indent after php closing tag
	if cline =~ '\M?>'
		let ind = ind - &sw
	endif

	if exists("b:php_noindent_switch") " version 1 behavior, diy switch/case,etc
		" Indent blocks enclosed by {} or ()
		if line =~ '[{(]\s*\(#[^)}]*\)\=$'
			let ind = ind + &sw
		endif
		if cline =~ '^\s*[)}]'
			let ind = ind - &sw
		endif
		return ind
	else " Post 0.1 behavior, main logic
		" Fix indenting for // and # style comments
		if line =~ '//' && cline =~ '//'
			let ind = lindent
			return ind
		endif
		if line =~ '#' && cline =~ '#'
			let ind = lindent
			return ind
		endif
		" Search the matching bracket (with searchpair()) and set the indent of
		" to the indent of the matching line.
		if cline =~ '^\s*}'
			call cursor(line('.'), 1)
			let ind = indent(searchpair('{', '', '}','bW', 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string"'))
			return ind
		endif
		" Try to indent switch/case statements as well
		" Indent blocks enclosed by {} or () or case statements, with some anal requirements
		if line =~ 'case.*:\|[{(]\s*\(#[^)}]*\)\=$'
			let ind = ind + &sw
			" return if the current line is not another case statement of the previous line is a bracket open
			if cline !~ '.*case.*:\|default:' || line =~ '[{(]\s*\(#[^)}]*\)\=$'
				return ind
			endif
		endif
		if cline =~ '^\s*case.*:\|^\s*default:\|^\s*[)}]'
			let ind = ind - &sw
			" if the last line is a break or return, or the current line is a close bracket,
			" or if the previous line is a default statement, subtract another
			if line =~ '^\s*break;\|^\s*return\|' && cline =~ '^\s*[)}]' && pline =~ 'default:'
				let ind = ind - &sw
			endif
		endif
		" Search the matching bracket (with searchpair()) and set the indent of cline
		" to the indent of the matching line.
		if cline =~ '^\s*}'
			call cursor(line('. '), 1)
			let ind = indent(searchpair('{', '', '}', 'bW', 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string"'))
			return ind
		endif

		if line =~ 'default:'
			let ind = ind + &sw
		endif

		if line =~ '/\*\s*\*/'
			" Last line contained a mixed comment open and close
			let ind = ind - 1
			return ind
		endif

		if line =~ '/\*'
			" Last line was the start of a comment section
			let ind = ind + 1
		endif
		if line =~ '\*/\s*$'
			" Last line was the end of a comment section
			let ind = ind - 1
		endif

		return ind
	endif
endfunction
" vim: set ts=4 sw=4:
