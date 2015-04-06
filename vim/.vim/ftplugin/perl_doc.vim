" Vim FT Plugin

" Maintainer:	Colin Keith <vim@ckeith.clara.net>
" Last Change:	2002 Jul 5
" Version:		1.1

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

if &keywordprg == '' | setlocal keywordprg=perldoc | endif   " See ':help K'
setlocal iskeyword=a-z,A-Z,48-57,:,/,. " Adds / and . as used in requires.

if !exists(':Perldoc')
  command! -n=? -buffer -complete=dir Perldoc :call s:Perldoc('<args>')
endif

"---
" Start the perldoc using the preferences from the global variables
"
function! s:Perldoc(perldoc)
  " set perldoc if not set
  let s:perldoc = a:perldoc
  if !exists(s:perldoc) || !strlen(s:perldoc)
    let s:line = getline('.')

    " Only use and require load stuff:
    " if its not a comment line
    if match(s:line, '^\s*\(use\|require\)') != -1
      let s:perldoc = substitute(s:line,
                      \ '^\s*use\s\+\([A-Za-z0-9_:]\+\).*', '\1','')

      " might be a require:
      if s:perldoc == s:line
        let s:perldoc = substitute(s:line,
                        \ "^\\s*require\\s\\+[\"']*\\([^\"']\\+\\).*", '\1', '')
        if s:perldoc != s:line
          let s:perldoc = substitute(s:perldoc, '^\(.\+\).pm', '\1', '')
          let s:perldoc = substitute(s:perldoc, '[\\/]', '::', 'g')
        endif
      endif
    endif
  endif

  " check got value
  if s:perldoc == ''
    echomsg 'What Perldoc Page do you want?'
    return
  endif

  " Check if Perldoc program exists:
  if exists('g:perldoc_program')
    let s:pdp = g:perldoc_program
  endif

  " Otherwise try the defaults:
  if !executable(s:pdp)
    if has('win32')
      let s:pdp = 'C:/Perl/bin/perldoc.bat'
    else
      let s:pdp = '/usr/bin/perldoc'
    endif

    if !executable(s:pdp)
      echoerr 'Perldoc Program not found (' . s:pdp . ')'
      return
    endif
  endif

  " Open new window along the top
  let s:height = winheight(0)
  if s:height > 0
    let s:height = s:height / 2
  elseif
    let s:height = 14
  endif

  " Now we have an executable to run, be more specific
  if &keywordprg == 'perldoc'
    silent! execute 'setlocal keywordprg='. s:pdp
  endif

  " Version 1.1.1 => g:perldoc_flag
  if !exists('g:perldoc_flag')
    if match(s:pdp, '\.bat$') == 0
      let s:perl = substitute(s:pdp, 'perldoc.bat', 'perl.exe', '')
    else
      let s:perl = substitute(s:pdp, 'perldoc', 'perl', '')
    endif

    " Generic name and rely on the system to expand it.
    if !executable(s:perl) | let s:perl = 'perl' | endif

    :top 1 new "Perl Version"
    silent! execute '1! '. s:perl.' -v'
    if match(getline(2), '^This is perl, v\([\d.]*\) ') == 0
      let g:perldoc_flag = '-U'
    else
      let g:perldoc_flag = ''
    endif

    :q!
  endif

  " Default to the user 'nobody'
  if g:perldoc_flag == 'su' | let g:perldoc_flag = 'su nobody' | endif
  if match(g:perldoc_flag, '^su ') == 0
    let s:cmd = g:perldoc_flag. ' -c "'. s:pdp.' -t '. s:perldoc .'"'
  else
    let s:cmd = s:pdp .' '. g:perldoc_flag . ' -t "'. s:perldoc .'"'
  endif

  silent! execute 'top '. s:height. 'new "Perldoc: ' .s:perldoc. '"'
  silent! execute '1! '. s:cmd
  redraw

  " Catch bad names
  if !match(getline(1), '^No documentation found for ')
    :quit!
    redraw | echomsg 'No such Perldoc as "' . s:perldoc . '"'
    return
  endif

  " Clean up the formatting a little:
  setlocal nomodified
  setlocal readonly
  setlocal filetype=podman

endfunction
