" Quickie key sequence to clean up and auto-format imports

" Before:
" import {
" Foo as   Quux        , Baz, Qux } from '@foo';
"
" After:
" import {
"     Foo as Quux,
"     Baz,
"     Qux,
" } from '@foo';

" join the import
normal vaBJ

" watch out for "Foo as Bar" imports
silent! s/  *as  */__AS__/g

silent! s/,//g

" surround with newlines
s/{/{\r/
s/}/\r}/

normal k<<

" split lines
silent! s/  */,\r/g
normal dd

" indent everything properly
normal =iB

" watch out for "Foo as Bar" imports
silent! %s/__AS__/ as /g

noh
