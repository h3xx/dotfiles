" vimrc
" vi: fdm=marker

" ***********************
" ***** environment *****
" ***********************

" Use Vim settings, rather then Vi settings (much better!). (default)
" This must be first, because it changes other options as a side effect.
"set nocompatible

" use filetype and indent plugins (default)
"filetype plugin indent on

" ****************************************
" ***** environment, Unicode options *****
" ****************************************

if has('multi_byte')
	" set the display encoding
	" (default is '', or 'utf-8' in the GUI)
	" addendum: idk, this seems to work for everything, however something
	" happens to set &termencoding to always be 'utf-8' at this point
	"
	" Settings at user interaction time:
	" term	LC_ALL	| &encoding	&termencoding
	" --------------+----------------------------
	" GUI	*	| utf-8		utf-8
	" xterm	*.utf8	| utf-8		utf-8
	" xterm -	| utf-8		latin1
	" uxterm -	| utf-8		utf-8
	if !has('gui_running')
		let &termencoding = &encoding
	endif
	" set the internal encoding
	set encoding=utf-8

	" &fileencoding (controls how characters in the internal encoding will
	" be written to the file) will be set according to &fileencodings
	" (default: 'ucs-bom', 'ucs-bom,utf-8,default,latin1' when &encoding
	"  is set to a Unicode value)
endif " has('multi_byte')

" *****************
" ***** mouse *****
" *****************

if has('mouse')
	"" when and where to use the mouse
	" 'n'	: Normal mode
	" 'v'	: Visual mode
	" 'i'	: Insert mode
	" 'c'	: Command-line mode
	" 'h'	: all previous modes when editing a help file
	" 'a'	: all previous modes
	" 'r'	: for hit-enter and more-prompt prompt
	" use mouse all the time (default)
	"set mouse=a
	" only use mouse when in normal/command mode
	" (this is so that middle-click for pasting in a terminal will work)
	set mouse=n

	" whether the window focus follows the mouse (default off)
	"" (I can see this becoming very annoying)
	"set nomousefocus
endif " has('mouse')

if !has('autocmd')
	" always set autoindenting on (default)
	"set autoindent
	" use smart indentation
	set smartindent

endif " !has("autocmd")

" ************************
" ***** backup files *****
" ************************

" always keep a backup (default)
"set backup

" skip backing up of the following patterns
"set backupskip+=/tmp/*

"" udev rules
"" (complains if there are files in the directory not matching *.rules)
set backupskip+=/etc/udev/rules.d/*

"" commit log messages
set backupskip+=*/svn-commit.tmp,*/COMMIT_EDITMSG

"" Slackware package special files
"" (if installed, will leave a rogue /install directory)
set backupskip+=*/install/slack-desc,*/install/slack-required,*/install/slack-suggests,*/install/doinst.sh

"" crontab files
"" (if left in the directory, they will execute twice)
set backupskip+=*/.cron/*/*

"" C-x C-e (bash)
set backupskip+=*/bash-fc-*

" ********************************
" ***** swap files, metadata *****
" ********************************

" keep vim swap files out of the current working directory
set directory=~/.vim/temp//

" number of characters typed before swap file is written (default)
"set updatecount=200

" number of milliseconds in interval between swap file writes (default)
"set updatetime=4000

" keep 512 lines of command line history
set history=512

" number of undo levels (default)
"set undolevels=1000

" supplemental spell file
"set spellfile=~/.vim/spell/en.ascii.add
"let &spellfile = "~/.vim/spell/".&spelllang.".".&encoding.".add"

" *********************************
" ***** filesystem navigation *****
" *********************************

" chdir to match current buffer
set autochdir

" automatically read a file if changed outside of vim (thanks vim-sensible)
set autoread

" ensure when opening in tabs, no tiny split windows (thanks vim-sensible)
set tabpagemax=50

" ensure every file opened from the command line gets opened in its own tab
" (except when running vimdiff)
" the same effect can be accomplished by running 'vim -p FILES'
if ! &diff
	tab all
endif

" ************************
" ***** command mode *****
" ************************

" display incomplete commands (default)
"set showcmd

" nice tab-completion on the command line
set wildmenu
" disable VCS files
set wildignore+=.git,.svn,CVS
" disable output files
set wildignore+=*.o,*.obj,*.class,*.gem
" disable temp and backup files
set wildignore+=*.swp,*~

" ***********************************
" ***** normal mode, navigation *****
" ***********************************

" start scrolling when we're 5 lines away from bottom/top margins
set scrolloff=5

" set lines to scroll when the cursor moves off screen (default)
"set scrolljump=1

" do incremental searching (default)
"set incsearch

" ********************************
" ***** normal mode, editing *****
" ********************************

" don't consider "octal" numbers when using C-a and C-x (thanks vim-sensible)
set nrformats-=octal

" don't add two spaces after a sentence-ending mark when gq-ing and j-ing
set nojoinspaces

" modify `formatlistpat' to include `*'-ed lists
"set formatlistpat=^\\s*\\d\\+\[\\]:.)}\\t\ ]\\s*			" default
"set formatlistpat=^\\s*\\(\\d\\+\\\|\\*\\\|-\\)[]:.)}\\t\ ]\\s*	" almost works
"set formatlistpat=^\\s*\\(\\d\\+[\\]:.)}\\t\ ]\\\|\\(\\*\\\|-\\)\\s\\)\\s*
set formatlistpat=^\\s*[\\d*]\\+\[\\]:.)}\\t\ ]\\s*

" **************************************
" ***** insert mode, formatoptions *****
" **************************************

"" bad options
" a	Automatic formatting of paragraphs.  Every time text is inserted or
"	deleted the paragraph will be reformatted.  See auto-format.
"	When the 'c' flag is present this only happens for recognized
"	comments.
" n	When formatting text, recognize numbered lists.  This actually uses
"	the 'formatlistpat' option, thus any kind of list can be used.  The
"	indent of the text after the number is used for the next line.  The
"	default is to find a number, optionally followed by '.', ':', ')',
"	']' or '}'.  Note that 'autoindent' must be set too.  Doesn't work
"	well together with "2".
"	Example: >
"		1. the first item
"		   wraps
"		2. the second item
" o	Automatically insert the current comment leader after hitting 'o' or
"	'O' in Normal mode.
" t	Automatic formatting of text using textwidth (but not comments)
" w	Trailing white space indicates a paragraph continues in the next line.
"	A line that ends in a non-white character ends a paragraph.
set formatoptions-=anotw

"" good options
" c	Auto-wrap comments using textwidth, inserting the current comment
"	leader automatically.
" r	Automatically insert the current comment leader after hitting <Enter>
"	in Insert mode.
" q	Allow formatting of comments with "gq" (here, mapped to "Q").
"	Note that formatting will not change blank lines or lines containing
"	only the comment leader.  A new paragraph starts after such a line,
"	or when the comment leader changes.
set formatoptions+=crq

" taken from vim-sensible ( https://github.com/tpope/vim-sensible )
if v:version > 703 || v:version == 703 && has("patch541")
	set formatoptions+=j " Delete comment character when joining commented lines
endif

" *******************
" ***** folding *****
" *******************

" (addendum: as I become more experienced, folding means less to me than quick
" navigation, i.e. if you depend on folds, you're doing it wrong)
"" indent : similarly-indented lines can fold
"" syntax : syntax highlighting definitions specify folds
"" manual : manually define folds (default)
""        : (fold paragraphs with `zfap')
set foldmethod=syntax

" all folds open upon opening a file (close with `zc')
set foldlevelstart=99

" *** syntax-specific folding options ***
" (note: /ftplugin/* executes after these options are interpreted, so they must
" be defined here)

"" perl
let perl_fold = 1
"let perl_fold_blocks = 1 " (screws up auto-indenting for some reason)
let perl_nofold_packages = 1

"" vim
"  0 or doesn't exist: no syntax-based folding
"  'a' : augroups
"  'f' : fold functions
"  'm' : fold mzscheme script
"  'p' : fold perl     script
"  'P' : fold python   script
"  'r' : fold ruby     script
"  't' : fold tcl      script
let g:vimsyn_folding = 'af'

"" php
"let g:php_folding = 1

" g:sh_fold_enabled - enable folding in sh files
" possible values:
"   0 : no syntax folding (default)
"   1 : enable function folding
"   2 : enable heredoc folding
"   4 : enable if/do/for folding
"   3 : enables function and heredoc folding
let g:sh_fold_enabled = 3

" ************************
" ***** key bindings *****
" ************************

" don't use Ex mode; use Q for formatting (default)
"map Q gq

" hitting ; in normal mode starts a command
nnoremap ; :

" remove search highlighting
nnoremap <ESC><ESC> :nohlsearch<CR>

" force opening new tabs when gf-ing
nnoremap gf <C-W>gf

" remap ctrl-[direction] to window moving
" (thanks to github.com/bling/minivimrc)
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" \v => re-select the text you just pasted
nnoremap <leader>v V`]

" visual shifting does not exit visual mode (thanks
" github.com/spf13/spf13-vim)
vnoremap < <gv
vnoremap > >gv

" C-u = undo in insert mode
inoremap <C-U> <C-G>u<C-U>

" yank from the cursor to the end of the line, to be consistent
" with C and D.
nnoremap Y y$

" H/L navigation = beginning/end of line
" (I have never pressed H or L expecting what they do by default)
nnoremap H ^
nnoremap L $

" ************************************
" ***** key bindings, paste mode *****
" ************************************

"" GUI clipboard operations
" Shift-Insert => paste
noremap <S-Insert> "+gP
" for insert mode
"map! <S-Insert> <C-R>+
" (these are better)
imap <S-Insert> <F10><C-R>+<F11>
cmap <S-Insert> <C-R>+

" Ctrl-Shift-Insert => paste after (insert mode N/A)
map <C-S-Insert> "+gp

" Ctrl-Insert => copy
"" line in command mode, selection in visual mode
nmap <C-Insert> "+yy
vmap <C-Insert> "+y

" Shift-Del => cut
"" line in command mode, selection in visual mode
nmap <S-Del> "+dd
vmap <S-Del> "+x

" paste mode
map <F10> :set paste<CR>
map <F11> :set nopaste<CR>
imap <F10> <C-O>:set paste<CR>
imap <F11> <nop>
set pastetoggle=<F11>

" *******************
" ***** display *****
" *******************

" show line numbers
set number

" allow backspacing over everything in insert mode (default)
"set backspace=2

" show the cursor position all the time (default)
"set ruler

" don't set the terminal title
" addendum: in a screen(1) session this means setting the text on the status
"	    bar, which is actually nice
"set notitle

" show the current mode (default)
"set showmode

" send more drawing commands to the terminal
set ttyfast

" ***************************
" ***** display, colors *****
" ***************************

" (if terminal is capable of more than monochrome)
if has('gui_running') || &t_Co > 2
	" Switch syntax highlighting on when the terminal has colors (default)
	"syntax on
	" Also switch on highlighting the last used search pattern. (default)
	"set hlsearch

	" stop the cursor from blinking, ever
	" addendum: this was to stop a bug where the cursor disappeared when
	" the window was maximized, but I decided to just never maximize
	" windows
	"set guicursor+=a:blinkon0

	" force more colors in the terminal than vim thinks is possible
	" (addendum: fixed 'the Right Way' by setting TERM=xterm-256color)
	"set t_Co=16 t_AB=[48;5;%dm t_AF=[38;5;%dm

	" Show trailing whitespace and spaces before a tab
	autocmd ColorScheme *		hi ExtraWhitespace ctermbg=red guibg=red

	" Show trailing whitespace and spaces before a tab
	"	(match commands only apply to the current buffer)
	autocmd BufEnter,WinEnter *	match ExtraWhitespace /\s\+$\| \+\ze\t/

	" Replace blinding gvim color scheme (makes terminal vim brighter)
	colorscheme late_evening

	" correct some colors
	" (addendum: only affects terminal vim, looks better regular)
	"highlight PreProc ctermfg=Magenta

	" highlight the current cursor line
	"set cursorline
	" addendum: hide the cursorline on inactive windows
	aug CursorLine
		au!
		au VimEnter * setl cursorline
		au WinEnter * setl cursorline
		au BufWinEnter * setl cursorline
		au WinLeave * setl nocursorline
	aug END

endif " has('gui_running') || &t_Co > 2

" ********************************
" ***** fancy plugin options *****
" ********************************

" *** vim-airline ***
set laststatus=2 noru
if has('gui_running')
	set guifont=Terminess\ Powerline\ 9
endif " has('gui_running')
" (hint: uxterm has the same font set)
if has('gui_running') || &termencoding == 'utf-8'
	let g:airline_powerline_fonts=1
	"let g:airline_left_sep = '▓░'
	"let g:airline_right_sep = '░▓'
endif
" mixed_indent_algo: the whitespace plugin is broken by default,
"	&tabstop aren't taken into effect when detecting mixed indent
let g:airline#extensions#whitespace#mixed_indent_algo=1
let g:airline_theme='badwolf'
let g:airline#extensions#tabline#show_buffers=0
let g:airline_extensions = ['branch', 'tabline', 'whitespace', 'tagbar']

" *** IDE plugin ***
let g:IDE_SyntaxScript = "~/.vim/plugin/ideSyntax.pl"
" default "fMOSTw"
"  's'" : disable warnings about being unable to generate syntax files (wtf)
let g:IDE_AdvancedFlags = "fMOsTw"

" *** nerdtree ***
" activate NERDTree when pressing the minus key
" (first make sure the window is comfortably wide)
" TODO	: make this faster
"	: candidates: NERDTreeMirror\|NERDTreeFind
"	:  function! NERDTreeInitAsNeeded()
"     redir => bufoutput
"     buffers!
"     redir END
"     let idx = stridx(bufoutput, "NERD_tree")
"     if idx > -1
"         NERDTreeMirror
"         NERDTreeFind
"         wincmd l
"     endif
" endfunction
if has('gui_running')
	nmap <silent> - :if &co<113\|set co=113\|endif\|NERDTreeToggle<CR>
else
	nmap <silent> - :NERDTreeToggle<CR>
endif
" ignore common RCS directories
let NERDTreeIgnore=['^CVS$', '\~$']
" don't use fancy Unicode characters on non-unicode terminals
if !has('gui_running') && &termencoding != 'utf-8'
	let NERDTreeDirArrows = 0
endif

" *** tagbar ***
let g:tagbar_autofocus = 1
let g:tagbar_ctags_bin = 'ctags'
"let g:tagbar_expand = 1 " doesn't work too well
if has('gui_running')
	nmap <silent> <F8> :packadd tagbar<CR>:if &co<113\|set co=113\|endif\|TagbarToggle<CR>
else
	nmap <silent> <F8> :packadd tagbar<CR>:TagbarToggle<CR>
endif

" ***********************************
" ***** syntax specific options *****
" ***********************************
" (note: /ftplugin/* executes after these options are interpreted, so they must
" be defined here)

"" perl extra coloring options
let perl_extended_vars = 1
let perl_want_scope_in_variables = 1
let perl_include_pod = 1

"" sh
" g:is_sh         : Borne shell (default)
" g:is_kornshell  : ksh
" g:is_posix      : same as ksh
" g:is_bash       : bash
let g:is_bash = 1

"" tohtml
"let g:html_use_encoding = 'utf-8'
let g:html_ignore_folding = 1
let g:html_use_css = 0

"" netrw
let g:netrw_http_cmd = 'curl -o'
let g:netrw_http_xcmd = '--silent >'
" press gx in normal mode to open the URL under the cursor
let g:netrw_browsex_viewer = 'google-chrome'

" ****************************
" ***** load local vimrc *****
" ****************************

if filereadable(expand("\~/.vimrc-local"))
	source \~/.vimrc-local
endif
