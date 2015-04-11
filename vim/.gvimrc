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
	nnoremap <C-W>v :set co=161\|vsplit<CR>

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

	if exists(':NERDTree') && !&diff
		" activate NERDTree
		" addendum: takes a long time to load file listings
		"au VimEnter * NERDTree|wincmd p

		" minus key toggles the file drawer (.vimrc)

		" make sure the window is wide enough
		set columns=113
	endif " exists(':NERDTree')

	" Stop the cursor from blinking, ever
	" addendum: this was to stop a bug where the cursor disappeared when the
	" window was maximized, but I decided to just never maximize windows
	"set guicursor+=a:blinkon0

endif " has('gui_running')
