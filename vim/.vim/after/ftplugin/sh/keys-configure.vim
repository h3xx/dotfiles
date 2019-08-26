" extra key combinations for Slackware package generation scripts

if expand("%:p:h") =~ '\(/_configure\|/build/scripts\)$'

	" ,p - dynamically patches from the default patch directory
	nnoremap <buffer> <silent> ,p :so ~/.vim/templates/keys/_configure-p.vim<CR>
	" ,l - dynamic libdir
	nnoremap <buffer> <silent> ,l :so ~/.vim/templates/keys/_configure-l.vim<CR>
	" ,d - shotgun doc install
	nnoremap <buffer> <silent> ,d :so ~/.vim/templates/keys/_configure-d.vim<CR>
	" ,c - cmake invocation quickie
	nnoremap <buffer> <silent> ,c :so ~/.vim/templates/keys/_configure-c.vim<CR>

	" further key combinations for build scripts

	if expand("%:p:t") =~ '-build$'
		" ,h - insert header text
		nnoremap <buffer> <silent> ,h :so ~/.vim/templates/keys/_configure-h.vim<CR>
		" ,H - insert header but with make_args array
		nnoremap <buffer> <silent> ,H :so ~/.vim/templates/keys/_configure-H.vim<CR>
		" ,i - install data
		nnoremap <buffer> <silent> ,i :so ~/.vim/templates/keys/_configure-i.vim<CR>
		" ,s - insert command for writing slack-desc
		nnoremap <buffer> <silent> ,s :so ~/.vim/templates/keys/_configure-s.vim<CR>
		" ,f - insert finisher text
		nnoremap <buffer> <silent> ,f :so ~/.vim/templates/keys/_configure-f.vim<CR>
	endif

endif
