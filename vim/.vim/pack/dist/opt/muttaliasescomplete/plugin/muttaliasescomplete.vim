" muttaliasescomplete.vim
" original Author: Karsten B <vim at kb.ccchl.de>
" modified by: Valentin H <valentin.haenel at gmx.de>

let g:aliases = []
let g:aliases_files = [ '~/.mutt/aliases', '~/.mutt/lists' ]

function! muttaliasescomplete#Init()
	for a:file in g:aliases_files
		call muttaliasescomplete#LoadFile(a:file)
	endfor
endfunction


function! muttaliasescomplete#LoadFile(filename)
	let a:nameMatch = glob(a:filename)
	if filereadable(a:nameMatch)
		for line in readfile(a:nameMatch)
			if match(line, 'alias') == 0
				let fields = split(line)
				call remove(fields, 0, 1)
				call add(g:aliases, join(fields, " "))
			endif
		endfor
	else
		echom 'file not readable' a:filename
	endif
endfunction


function! muttaliasescomplete#Complete(findstart, base)
	" cache aliases
	if g:aliases == []
		call muttaliasescomplete#Init()
	endif

	
	" find beginning of the current address
	if a:findstart
		let line = getline('.')
		let start = col('.') -1
		while line[start -2] != ',' && line[start -2] != ':' && start > 0
			let start -= 1
		endwhile

		return start
	endif


	" TODO check if an address is required in this line (To:, Cc:, ...)


	" complete an empty start, return all aliases
	if a:base == ''
		return g:aliases
	endif


	let matches = []
	let needle = '\c' . a:base
	for item in g:aliases
		if match(item, needle) != -1
			call add(matches, item)
		endif
	endfor

	return matches
endfunction

