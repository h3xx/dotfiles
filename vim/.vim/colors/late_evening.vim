" Vim color file
" Maintainer:	Dan Church
" Last Change:	2015 Jun 26

" This color scheme uses a *really* dark grey background.
"
" Forked from evening.vim with the following tweaks:

" ** Aesthetic fixes **
" - Almost black backgrounds
" - Cursorline not so bright as to make comments disappear
" - Brighter cursor
" - Brighter green messages
" - Nicer colors on line numbers (like comments with the current line
"   highlighted if &cursorline)
" - Replace awful-looking yellow-on-white when using wildmenu

" ** Bug fixes **
" - Text mode: fix invisible visual mode selection
" - Fix inability to see netrw marked files when using gui fonts that don't
"   like bold (type mf in netrw, controlled by TabLineSel highlight)
" - Fix many inconsistencies between gui and console (evening.vim):
"   * PreProc: blue in console, magenta in gui
"   * Comment: cyan in console, blue in gui
"   * CursorLine: underline in console (256 colors), gray in gui
"   * Special: salmon in console (256 colors), red in console (8 colors),
"     orange in gui

" First remove all existing highlighting.
set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif

let colors_name = "late_evening"

hi Normal ctermbg=black ctermfg=White guifg=White guibg=grey5

" Groups used in the 'highlight' and 'guicursor' options default value.
hi ErrorMsg term=standout ctermbg=DarkRed ctermfg=White guibg=Red guifg=White
hi IncSearch term=reverse cterm=reverse gui=reverse
hi ModeMsg term=bold cterm=bold gui=bold
hi StatusLine term=bold cterm=none ctermbg=238 gui=bold guibg=grey20
hi StatusLineNC term=reverse cterm=reverse gui=reverse
hi VertSplit term=reverse cterm=reverse gui=reverse
hi Visual term=reverse cterm=reverse ctermbg=black guibg=grey40
hi VisualNOS term=underline,bold cterm=underline,bold gui=underline,bold
hi DiffText term=reverse cterm=bold ctermbg=Red gui=bold guibg=Red
hi Cursor guibg=lightgreen guifg=Black
hi lCursor guibg=Cyan guifg=Black
hi Directory term=bold ctermfg=LightCyan guifg=Cyan
hi LineNr term=underline ctermfg=blue guifg=steelblue
hi MoreMsg term=bold ctermfg=82 gui=bold guifg=#60ff60
hi NonText term=bold ctermfg=LightBlue gui=bold guifg=LightBlue guibg=grey10
hi Question term=standout ctermfg=82 gui=bold guifg=#60ff60
hi Search term=reverse ctermbg=Yellow ctermfg=Black guibg=Yellow guifg=Black
hi SpecialKey term=bold ctermfg=LightBlue guifg=Cyan
hi Title term=bold ctermfg=165 gui=bold guifg=Magenta
hi WarningMsg term=standout ctermfg=196 guifg=Red
hi WildMenu term=standout ctermbg=Yellow ctermfg=Black guibg=Yellow guifg=Black
hi Folded term=standout ctermbg=LightGrey ctermfg=DarkBlue guibg=LightGrey guifg=DarkBlue
hi FoldColumn term=standout ctermbg=LightGrey ctermfg=DarkBlue guibg=Grey guifg=DarkBlue
hi DiffAdd term=bold ctermbg=DarkBlue guibg=DarkBlue
hi DiffChange term=bold ctermbg=DarkMagenta guibg=DarkMagenta
hi DiffDelete term=bold ctermfg=Blue ctermbg=DarkCyan gui=bold guifg=Blue guibg=DarkCyan
hi CursorColumn term=reverse ctermbg=238 guibg=grey30
hi CursorLine term=underline cterm=none ctermbg=238 guibg=grey30
hi Comment cterm=bold ctermfg=blue
hi TabLineSel term=bold cterm=reverse gui=reverse
hi Type ctermfg=82 guifg=#60ff60

hi Ignore ctermfg=DarkGrey guifg=grey20
" Groups for syntax highlighting
hi Constant term=underline ctermfg=217 guifg=#ffa0a0 guibg=grey5
hi Special term=bold ctermfg=LightRed guifg=Orange guibg=grey5
" bug fix
hi PreProc ctermfg=magenta

" Modifications for more colors
if &t_Co > 8
  hi Statement term=bold cterm=bold ctermfg=Yellow guifg=#ffff60 gui=bold
endif

" Low color support
if &t_Co < 17
  hi CursorLine cterm=underline ctermbg=none
  hi CursorColumn cterm=reverse ctermbg=Black
  hi StatusLine cterm=bold ctermbg=black
  hi Type ctermfg=green
  hi MoreMsg ctermfg=LightGreen
  hi Question ctermfg=LightGreen
  hi Title ctermfg=LightMagenta
  hi WarningMsg ctermfg=LightRed
  hi Constant ctermfg=Magenta
endif

" vim: sw=2
