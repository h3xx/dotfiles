" Vim color file
" Maintainer:	Dan Church
" Last Change:	2015 Jun 26

" This color scheme uses a *really* dark grey background.
"
" Forked from evening.vim with the following tweaks:
" - Almost black backgrounds
" - Cursorline not so bright as to make comments disappear
" - Brighter cursor
" - Brighter green messages
" - Nicer colors on line numbers (like comments with the current line
"   highlighted if &cursorline)
" - Text mode: fix invisible visual mode selection
" - Text mode: comment color more like gui mode
" - GUI-like cursorline in terminals with a lot of colors
" - Fix yellow-on-white (sort of) in GUI, 16-color and 256-color terminals
"   (test &wildmenu)
" - Fix dark green messages in command mode.
" - Fix inability to see netrw marked files when using gui fonts that don't
"   like bold (type mf in netrw, controlled by TabLineSel highlight)

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
hi StatusLine term=bold cterm=bold ctermbg=black gui=bold guibg=grey20
hi StatusLineNC term=reverse cterm=reverse gui=reverse
hi VertSplit term=reverse cterm=reverse gui=reverse
hi Visual term=reverse cterm=reverse ctermbg=black guibg=grey40
hi VisualNOS term=underline,bold cterm=underline,bold gui=underline,bold
hi DiffText term=reverse cterm=bold ctermbg=Red gui=bold guibg=Red
hi Cursor guibg=lightgreen guifg=Black
hi lCursor guibg=Cyan guifg=Black
hi Directory term=bold ctermfg=LightCyan guifg=Cyan
hi LineNr term=underline ctermfg=blue guifg=steelblue
hi MoreMsg term=bold ctermfg=LightGreen gui=bold guifg=#60ff60
hi NonText term=bold ctermfg=LightBlue gui=bold guifg=LightBlue guibg=grey10
hi Question term=standout ctermfg=LightGreen gui=bold guifg=#60ff60
hi Search term=reverse ctermbg=Yellow ctermfg=Black guibg=Yellow guifg=Black
hi SpecialKey term=bold ctermfg=LightBlue guifg=Cyan
hi Title term=bold ctermfg=LightMagenta gui=bold guifg=Magenta
hi WarningMsg term=standout ctermfg=LightRed guifg=Red
hi WildMenu term=standout ctermbg=Yellow ctermfg=Black guibg=Yellow guifg=Black
hi Folded term=standout ctermbg=LightGrey ctermfg=DarkBlue guibg=LightGrey guifg=DarkBlue
hi FoldColumn term=standout ctermbg=LightGrey ctermfg=DarkBlue guibg=Grey guifg=DarkBlue
hi DiffAdd term=bold ctermbg=DarkBlue guibg=DarkBlue
hi DiffChange term=bold ctermbg=DarkMagenta guibg=DarkMagenta
hi DiffDelete term=bold ctermfg=Blue ctermbg=DarkCyan gui=bold guifg=Blue guibg=DarkCyan
hi CursorColumn term=reverse ctermbg=Black guibg=grey30
hi CursorLine term=underline cterm=underline guibg=grey30
hi Comment cterm=bold ctermfg=blue
hi TabLineSel term=bold cterm=reverse gui=reverse

" Groups for syntax highlighting
hi Constant term=underline ctermfg=Magenta guifg=#ffa0a0 guibg=grey5
hi Special term=bold ctermfg=LightRed guifg=Orange guibg=grey5
" bug fix
hi PreProc ctermfg=magenta

" Modifications for more colors
if &t_Co > 8
  hi Statement term=bold cterm=bold ctermfg=Yellow guifg=#ffff60 gui=bold
endif
if &t_Co > 16
  hi CursorLine cterm=none ctermbg=238
  hi StatusLine cterm=none ctermbg=238
"  hi StatusLineNC ctermfg=12 ctermbg=248
  hi Type ctermfg=82
  hi MoreMsg ctermfg=82
  hi Question ctermfg=82
  hi Title ctermfg=165
  hi WarningMsg ctermfg=196
  hi Constant ctermfg=217
endif
hi Ignore ctermfg=DarkGrey guifg=grey20

" vim: sw=2
