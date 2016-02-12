" Inline control block -> explicit braces
" e.g.
"
" if ($foo)
"    bar();|
"
" becomes
"
" if ($foo) {
"    bar();|
" }
exe "norm kA {\<Esc>jo}\<Esc>k^"
