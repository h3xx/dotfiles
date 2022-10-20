" textobj-entire - Text objects for entire buffer
" Version: 0.0.3
" Copyright (C) 2009-2014 Kana Natsuno <http://whileimautomaton.net/>
" (Modded slightly by Dan Church, credit still goes to Kana Natsuno)
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}

if exists('g:loaded_textobj_entire')  "{{{1
  finish
endif








" Interface  "{{{1

call textobj#user#plugin('entire', {
\      '-': {
\        '*sfile*': expand('<sfile>:p'),
\        'select-a': 'aE',  '*select-a-function*': 's:select_a',
\        'select-i': 'iE',  '*select-i-function*': 's:select_i'
\      }
\    })








" Misc.  "{{{1
function! s:select_a()
  " To easily back to the last position after a command.
  " For example: yaE<C-o>
  mark '

  keepjumps normal! gg0
  let start_pos = getpos('.')

  keepjumps normal! G$
  let end_pos = getpos('.')

  return ['V', start_pos, end_pos]
endfunction

function! s:select_i()
  " To easily back to the last position after a command.
  " For example: yie<C-o>
  mark '

  keepjumps normal! gg0
  call search('^.', 'cW')
  let start_pos = getpos('.')

  keepjumps normal! G$
  call search('^.', 'bcW')
  normal! $
  let end_pos = getpos('.')

  return ['V', start_pos, end_pos]
endfunction








" Fin.  "{{{1

let g:loaded_textobj_entire = 1








" __END__
" vim: foldmethod=marker
