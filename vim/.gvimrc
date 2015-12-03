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

	" T: no toolbar (useless)
	" m: no menu (gets in the way of using Meta in key combos)
	set guioptions-=T guioptions-=m


	if has('mouse')
		set mouse=n
	endif " has('mouse')

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

	" Stop the cursor from blinking, ever
	" addendum: this was to stop a bug where the cursor disappeared when
	" the window was maximized, but I decided to just never maximize
	" windows
	"set guicursor+=a:blinkon0

endif " has('gui_running')
