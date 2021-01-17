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
	" Set the display encoding
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
		let &termencoding=&encoding
	else
		set encoding=utf-8
	endif
	" set the internal encoding (messes up terminal encoding detection)
	"set encoding=utf-8

	" &fileencoding (controls how characters in the internal encoding will be
	" written to the file) will be set according to &fileencodings
	" (default: 'ucs-bom', 'ucs-bom,utf-8,default,latin1' when &encoding is set
	" to a Unicode value)
endif " has('multi_byte')

" *****************
" ***** mouse *****
" *****************

if has('mouse')
	"" When and where to use the mouse
	" n Normal mode
	" v Visual mode
	" i Insert mode
	" c Command-line mode
	" h all previous modes when editing a help file
	" a all previous modes
	" r for hit-enter and more-prompt prompt
	" use mouse all the time (default)
	"set mouse=a
	" Never use the mouse!
	" (middle-click for pasting in a terminal will still work)
	set mouse=

	" whether the window focus follows the mouse (default off)
	"" (I can see this becoming very annoying)
	"set nomousefocus
endif " has('mouse')

" ************************
" ***** backup files *****
" ************************

" Always keep a backup (default)
"set backup

" Skip backing up of the following patterns
" default: "/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*"

" ********************************
" ***** swap files, metadata *****
" ********************************

" Hide those backups
set backupdir=~/.vim/temp//

" Keep vim swap files out of the current working directory
set directory=~/.vim/temp//

" Keep vim undo files out of the current working directory
set undodir=~/.vim/temp//

" Number of characters typed before swap file is written (default)
"set updatecount=200

" Number of milliseconds in interval between swap file writes (default)
"set updatetime=4000

" Keep 512 lines of command line history
set history=512

" Number of undo levels (default)
"set undolevels=1000

" Supplemental spell file
"set spellfile=~/.vim/spell/en.ascii.add
"let &spellfile='~/.vim/spell/'.&spelllang.'.'.&encoding.'.add'

" *********************************
" ***** filesystem navigation *****
" *********************************

" Change directory to match current buffer
"set autochdir
" (slightly better; don't chdir when buffer is on, e.g. a fugitive commit
" buffer, or a :Gblame buffer)
aug AutoChdir
	autocmd!
	autocmd BufEnter *	if expand("%:p") !~ '\(/\.git/\|\.fugitiveblame$\)' | silent! lcd %:p:h | endif
aug END

" Automatically read a file if changed outside of vim (thanks vim-sensible)
set autoread

" ensure when opening in tabs, no tiny split windows (thanks vim-sensible)
set tabpagemax=50

" ************************
" ***** command mode *****
" ************************

" Display incomplete commands (default)
"set showcmd

" nice tab-completion on the command line
set wildmenu
" disable VCS files
set wildignore+=.git,.svn,CVS
" disable output files
set wildignore+=*.o,*.obj,*.class,*.gem
" disable temp and backup files
set wildignore+=*.swp,*~
" git merge poop files
set wildignore+=*_BACKUP_*,*_BASE_*,*_LOCAL_,*_REMOTE_*,*.orig

" ******************************
" ***** command mode, grep *****
" ******************************

" To get ack, use:
" $ wget -O ~/bin/ack http://beyondgrep.com/ack-2.14-single-file && chmod +x ~/bin/ack
if executable('ack')
	" use ack over grep (automatically ignores *~)
	set grepprg=ack\ --nogroup\ --nocolor
else
	" ignore backup files when using :grep
	set grepprg=grep\ -n\ --exclude=*~\ $*\ /dev/null
endif " executable('ack')

" ***********************************
" ***** normal mode, navigation *****
" ***********************************

" Do incremental searching (default)
"set incsearch

" Set lines to scroll when the cursor moves off screen (default)
"set scrolljump=1

" Start scrolling when the cursor is x lines away from bottom/top margins
" (default)
"set scrolloff=5

" do not time out when entering mapped key sequences
" (addendum: does not work well with imapped F1-F10 keys because they send
" "\eO? in xterm)
"set notimeout

" ********************************
" ***** normal mode, editing *****
" ********************************

" Default ai- and gq-wrapping width
"set textwidth=79

" Don't add two spaces after a sentence-ending mark when gq-ing and j-ing
set nojoinspaces

" Don't consider "octal" numbers when using C-a and C-x (thanks vim-sensible)
set nrformats-=octal

" Modify `formatlistpat' to include `*'-ed lists
"set formatlistpat=^\\s*\\d\\+\[\\]:.)}\\t\ ]\\s*			" default
"set formatlistpat=^\\s*\\(\\d\\+\\\|\\*\\\|-\\)[]:.)}\\t\ ]\\s*	" almost works
"set formatlistpat=^\\s*\\(\\d\\+[\\]:.)}\\t\ ]\\\|\\(\\*\\\|-\\)\\s\\)\\s*
set formatlistpat=^\\s*[\\d*]\\+\[\\]:.)}\\t\ ]\\s*

" ***********************
" ***** insert mode *****
" ***********************

" Make indenting less stupid
set autoindent smartindent

" Less conspicuous tab indentation
set tabstop=4 shiftwidth=4

"" bad options
" a	Automatic formatting of paragraphs. Every time text is inserted or deleted
"	the paragraph will be reformatted. See auto-format. When the 'c' flag is
"	present this only happens for recognized comments.
" n	When formatting text, recognize numbered lists. This actually uses the
"	'formatlistpat' option, thus any kind of list can be used. The indent of the
"	text after the number is used for the next line. The default is to find a
"	number, optionally followed by '.', ':', ')', ']' or '}'. Note that
"	'autoindent' must be set too. Doesn't work well together with "2".
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
" c	Auto-wrap comments using textwidth, inserting the current comment leader
"	automatically.
" r	Automatically insert the current comment leader after hitting <Enter>
"	in Insert mode.
" q	Allow formatting of comments with "gq" (here, mapped to "Q"). Note that
"	formatting will not change blank lines or lines containing only the comment
"	leader. A new paragraph starts after such a line, or when the comment leader
"	changes.
set formatoptions+=crq

" Taken from vim-sensible (https://github.com/tpope/vim-sensible)
if v:version > 703 || has('patch541')
	" Delete comment character when joining commented lines
	set formatoptions+=j
endif

" *******************
" ***** folding *****
" *******************

" (addendum: as I become more experienced, folding means less to me than quick
" navigation, i.e. if you depend on folds, you're doing it wrong)
" 0: all folds closed upon opening a file
" 99: all folds open (close with `zc')
set foldlevelstart=99

" ************************
" ***** key bindings *****
" ************************

" don't use Ex mode; use Q for formatting (default)
"map Q gq

" allow backspacing over everything in insert mode (default)
"set backspace=2

" two-stroke saving instead of four-stroke
" usefulness: *****
nnoremap <C-s> :w<cr>

" Alt+s, Alt+p, Alt+f = common fugitive commands
" rhymes with .inputrc mapping
" usefulness: *****
nnoremap <A-s> :Gst<cr>
" usefulness: ****
nnoremap <A-p> :Gpush 
" usefulness: **
nnoremap <A-f> :Gfetch
" usefulness: ***
nnoremap <A-u> :Gpull
" usefulness: TODO
nnoremap <A-o> :Git co 

" git blame
" usefulness: ****
nnoremap <F2> :Gblame<cr>

" reverse function of ' and `
" ' => more accurate jumping, ` => less accurate jumping
" usefulness: ****
noremap ` '
noremap ' `

" Search for v-highlighted string
" usefulness: TODO
vnoremap // y/\V<C-R>"<CR>

" Remove search highlighting
" usefulness: ****
nnoremap <F1> :noh<CR>

" force opening new tabs when gf-ing
" usefulness: ***
nnoremap gf <C-W>gf

" remap ctrl-[direction] to window moving
" (thanks to github.com/bling/minivimrc)
" usefulness: *****
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l

" \v => re-select the text you just pasted
" usefulness: **
nnoremap <leader>v V`]

" yank from the cursor to the end of the line, to be consistent
" with C and D.
" usefulness: **
nnoremap Y y$

" H/L navigation = beginning/end of line
" (I have never pressed H or L expecting what they do by default)
" usefulness: *****
noremap H ^
noremap L $

" override default C-u, C-d scrolling because I don't like it
" usefulness: ***
nnoremap <C-u> 10k
nnoremap <C-d> 10j

" sort indented lists
" usefulness: ****
nmap \s vii:!sort -u<cr>
" same thing but case-insensitive and only considering letters
nmap \S vii:!sort -fud<cr>

" ************************************
" ***** key bindings, paste mode *****
" ************************************

" Paste mode
" usefulness: ****
map <F10> :set paste<CR>
map <F11> :set nopaste<CR>
imap <F10> <C-O>:set paste<CR>
imap <F11> <nop>
set pastetoggle=<F11>

" *******************
" ***** display *****
" *******************

" Disable preview window when completing
set completeopt-=preview
" Make it obvious I'm completing
set completeopt+=menuone

" Do not redraw screen until macros, etc. are done drawing to the screen
" (better responsiveness over SSH and slow terminals)
set lazyredraw

" Show line numbers
set number

" Show the cursor position all the time (default)
"set ruler

" I: Disable startup message
" c: Don't give useless ins-completion-menu messages in the statusbar
set shortmess+=I
if v:version > 704 || has("patch314")
	set shortmess+=c
endif

" Show the current mode (default)
"set showmode

" Don't set the terminal title
" addendum: in a screen(1) session this means setting the text on the status
" bar, which is actually nice
" addendum1: tmux not so much
set notitle

" Send more drawing commands to the terminal
set ttyfast

" ***************************
" ***** display, colors *****
" ***************************

" Switch syntax highlighting on when the terminal has colors (default)
"syntax on
" Also switch on highlighting the last used search pattern. (default)
"set hlsearch

" force more colors in the terminal than vim thinks is possible
" (addendum: fixed 'the Right Way' by setting TERM=xterm-256color)
"set t_Co=16 t_AB=[48;5;%dm t_AF=[38;5;%dm

" Show trailing whitespace and spaces before a tab
" (note: must occur BEFORE colorscheme invocation)
autocmd ColorScheme * hi ExtraWhitespace term=reverse ctermbg=red guibg=red
" (match commands only apply to the current buffer)
autocmd BufEnter,WinEnter * match ExtraWhitespace /\s\+$\| \+\ze\t/

" *** lightline.vim
" make mode bold
autocmd ColorScheme *
			\ hi LightLineLeft_normal_0 term=bold cterm=bold |
			\ hi LightLineLeft_insert_0 term=bold cterm=bold |
			\ hi LightLineLeft_visual_0 term=bold cterm=bold |
			\ hi LightLineLeft_replace_0 term=bold cterm=bold |
			\ hi LightLineLeft_command_0 term=bold cterm=bold


" Replace blinding gvim color scheme (makes terminal vim brighter)
colorscheme late_evening

" Correct some colors
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

" ********************************
" ***** fancy plugin options *****
" ********************************

" *** lightline.vim

set laststatus=2 noru noshowmode

let g:lightline={
			\ 'colorscheme': 'badwolf',
			\ 'component': {
			\   'lineinfo': '¶ %3l:%-2v',
			\ },
			\ 'active': {
			\   'left': [ [ 'mode', 'paste' ], [ 'fugitive' ], [ 'filename', 'file_flags' ] ],
			\ },
			\ 'component_function': {
			\   'readonly': 'LightLineReadonly',
			\   'modified': 'LightLineModified',
			\   'file_flags': 'LightLineFileFlags',
			\   'filename': 'LightLineFilename',
			\   'fileformat': 'LightLineFileformat',
			\   'filetype': 'LightLineFiletype',
			\   'fileencoding': 'LightLineFileencoding',
			\   'fugitive': 'LightLineFugitive',
			\ },
			\ 'separator': { 'left': '»', 'right': '«' },
			\ 'subseparator': { 'left': '>', 'right': '<' },
			\ 'tabline_separator': { 'left': '', 'right': '' },
			\ 'tabline_subseparator': { 'left': '', 'right': '' },
			\ }

function! LightLineReadonly()
	return &ft != 'help' && &readonly ? '[RO]' : ''
endfunction

function! LightLineModified()
	return &modified ? '[+]' : &modifiable ? '' : '[-]'
endfunction

function! LightLineFilename()
	let fname=expand('%')
	return '' != fname ? fname : '[No Name]'
endfunction

function! LightLineFileFlags()
	return LightLineModified() . LightLineReadonly()
endfunction

"function! LightLineFilenameDecorated()
"	let m=LightLineModified()
"	let r=LightLineReadonly()
"	return
"				\ ('' != r ? r . ' ' : '') .
"				\ LightLineFilename() .
"				\ m
"endfunction

function! LightLineFileformat()
	" only show unexpected fileformats
	return winwidth(0) > 70 && &fileformat != 'unix' ? &fileformat : ''
endfunction

function! LightLineFiletype()
	return winwidth(0) > 70 ? &filetype : ''
endfunction

function! LightLineFileencoding()
	" only show unexpected fileencodings (expected is &enc)
	return winwidth(0) > 70 && &fenc == &enc ? '' : &fenc .
				\ (&bomb ? '[bom]' : '')
endfunction

function! LightLineFugitive()
	if exists('*fugitive#head')
		let _=fugitive#head()
		return strlen(_) ? 'µ '._ : ''
	endif
	return ''
endfunction

if &encoding == 'utf-8'
	let g:lightline.separator.right='Â«'
	let g:lightline.separator.left='Â»'
	let g:lightline.component.lineinfo=substitute(g:lightline['component']['lineinfo'], '¶', 'Â¶', 'g')
	function! LightLineFugitive()
		if exists('*fugitive#head')
			let _=fugitive#head()
			return strlen(_) ? 'Âµ '._ : ''
		endif
		return ''
	endfunction
endif

" *** vim-gitgutter ***
" wait until I save the file to update signs
let g:gitgutter_realtime=0
let g:gitgutter_eager=0
" Support non-utf8 terminals
let g:gitgutter_sign_removed_first_line='^'

" *** tagbar ***
if has('gui_running')
	nmap <silent> <F8> :packadd tagbar<CR>:if &co<113\|set co=113\|endif\|TagbarToggle<CR>
else
	nmap <silent> <F8> :packadd tagbar<CR>:TagbarToggle<CR>
endif
let g:tagbar_autofocus=1
let g:tagbar_ctags_bin='ctags'
"let g:tagbar_expand=1 " doesn't work too well

" *** ctrl-p ***
" c-t is unusable here because it's mapped in tmux
let g:ctrlp_prompt_mappings={
	\ 'AcceptSelection("t")': ['<c-g>'],
	\ }

" don't get lost in the largest man-made structure on earth
let g:ctrlp_custom_ignore={
	\ 'dir':  '\v[\/]node_modules$',
	\ }

" If multiple vim sessions are open in the same directory, it'll clobber each
" others' caches.
" Work around stale caches by pressing F5 in the Ctrl P search panel.
let g:ctrlp_clear_cache_on_exit=0

" *** arcane plugins ***
" prevent some built-in, unused plugins from loading
let g:loaded_vimballPlugin=1
let g:loaded_getscriptPlugin=1

" ***********************************
" ***** syntax specific options *****
" ***********************************
" (note: /ftplugin/* executes after these options are interpreted, so they must
" be defined here)

"" Perl extra coloring options
let perl_extended_vars=1
let perl_want_scope_in_variables=1
let perl_include_pod=1

"" PHP-Indenting-for-VIm
" No stupid arrow indenting esp. during mock object creation
let g:PHP_noArrowMatching=1
" Indent case statements according to PEAR standards
let g:PHP_vintage_case_default_indent=1

"" sh
" g:is_sh Borne shell (default)
" g:is_kornshell ksh
" g:is_posix same as ksh
" g:is_bash bash
let g:is_bash=1

"" netrw
" press gx in normal mode to open the URL under the cursor
let g:netrw_browsex_viewer='google-chrome'
" use tree style with decorations
let g:netrw_liststyle=3
" Show the banner but fold it (see .vim/after/ftplugin/netrw.vim)
let g:netrw_banner=1
" horizontally split the window when opening a file via <cr>
let g:netrw_browse_split=4
" preview window shown in a vertically split window
let g:netrw_preview=1
" split files below, right
let g:netrw_alto=1
let g:netrw_altv=1
" ignore some filename patterns
" note: netrw loves to append characters to filenames sometimes for no reason
" all entries:    [/*|@=]\?
" regular files:  [*|@=]\?
" directories:    /
" ignore dot files, swap files and backup files (regular files only)
let g:netrw_list_hide='\(\~\|^\..*\.swp\)[*|@=]\?$'
" ignore all RCS dirs (directories only)
let g:netrw_list_hide.=',^\(CVS\|\.git\|\.svn\|\.hg\)/$'
" ignore CVS backups (regular files only)
let g:netrw_list_hide.=',^\.#.*[*|@=]\?$'

let g:netrw_hide=1
" note: setting this variable causes weird effects when opening files via <cr>
"let g:netrw_winsize=26
" activate netrw at 26 characters width when pressing the minus key
nmap <silent> - :26Vexplore<CR>

" bug workaround:
" set bufhidden=wipe in netrw windows to circumvent a bug where vim won't let
" you quit (!!!) if a netrw buffer doesn't like it
" also buftype should prevent you from :w
" (reproduce bug by opening netrw, :e ., :q)
let g:netrw_bufsettings='noma nomod nonu nobl nowrap ro' " default
let g:netrw_bufsettings.=' buftype=nofile bufhidden=wipe'

" Ensure every file opened from the command line gets opened in its own tab
" (except when running vimdiff)
" The same effect can be accomplished by running 'vim -p FILES'
" (note: this must occur last because sometime netrw causes issues)
if ! &diff
	tab all
endif
