" extra key combinations for Slackware package generation scripts

if expand("%:p:h") =~ '\(/_configure\|/build/scripts\)$'

	" ,p - dynamically patches from the default patch directory
	nnoremap <buffer> <silent> ,p :ru templates/keys/_configure-apply-patches.vim<CR>
	" ,l - dynamic libdir
	nnoremap <buffer> <silent> ,l :ru templates/keys/_configure-libdir.vim<CR>
	" ,d - shotgun doc install
	nnoremap <buffer> <silent> ,d :ru templates/keys/_configure-doc-install.vim<CR>
	" ,c - cmake invocation quickie
	nnoremap <buffer> <silent> ,c :ru templates/keys/_configure-cmake-invoke.vim<CR>

	" further key combinations for build scripts

	if expand("%:p:t") =~ '-build$'
		" ,h - insert header text
		nnoremap <buffer> <silent> ,h :ru templates/keys/_configure-header.vim<CR>
		" ,H - insert header but with make_args array
		nnoremap <buffer> <silent> ,H :ru templates/keys/_configure-header-with-make-args.vim<CR>
		" ,i - install data
		nnoremap <buffer> <silent> ,i :ru templates/keys/_configure-install-0644.vim<CR>
		" ,S - insert command for writing slack-desc
		nnoremap <buffer> <silent> ,S :ru templates/keys/_configure-slack-desc.vim<CR>
		" ,f - insert finisher text
		nnoremap <buffer> <silent> ,f :ru templates/keys/_configure-finisher.vim<CR>
	endif

endif
