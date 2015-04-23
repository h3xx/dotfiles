" gvimrc

if has('gui_running')
	" set window dimensions
	set lines=59
	if &diff
		" wide view for (g)vimdiff
		set columns=160
	endif " &diff

	" make the window double-wide when splitting windows
	" (this isn't exact for some reason; windows aren't set to 80 columns)
	nnoremap <C-W>v :if &co<161\|set co=161\|endif\|vsplit<CR>

	" highlight the current cursor line
	" (not enabled in terminal mode because it looks ugly)
	"set cursorline
	" addendum: hide the cursorline on inactive windows
	aug CursorLine
		au!
		au VimEnter * setl cursorline
		au WinEnter * setl cursorline
		au BufWinEnter * setl cursorline
		au WinLeave * setl nocursorline
	aug END

	" don't set the terminal title
	set title

	" no toolbar (useless)
	set guioptions-=T

	" Fancy Plugin Options

"	if exists(':Airline')
"		" for airline
"		"set guifont=DejaVu\ Sans\ Mono\ for\ Powerline
"		"set guifont=Liberation\ Mono\ for\ Powerline
"
"		"set guifont=Droid\ Sans\ Mono\ for\ Powerline\ 9
"		set guifont=Terminess\ Powerline\ 9
"
"		let g:airline_powerline_fonts=1
"	endif " exists(':Airline')

endif " has('gui_running')
