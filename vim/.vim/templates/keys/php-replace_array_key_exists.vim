" Replace array_key_exists() with isset()
" Needed for PHP 8.0 migration [only when used with objects]
" See https://www.php.net/manual/en/migration80.incompatible.php

" When it's done it'll turn this:
" array_key_exists('bar', $foo)
" into this:
" isset($foo['bar'])
" Depends on vim-textobj-parameter ("yi,da,")
" Depends on vim-surround ("ysi,]")

" Find the start
exe "norm! ?\\<array_key_exists\\s*(\<CR>"
" Replace the function
exe "norm! ct(isset\<Esc>"
" Jump to the right banana
" Delete the last argument
" Surround the first argument with []
" Paste the bare last argument before the first, e.g. $last['first']
norm %h"1yi,da,%lysi,]"1P"
