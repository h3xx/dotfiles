" insert vim hint line that sets the filetype and other options

" Default file options
" Format:
" $option_short => $default_value
" -OR-
" $option_short => [
"	$default_value,
"	{
"		$val1: $hintline_to_set_val1,
"		$val2: $hintline_to_set_val2,
"		...
"   } ]
let s:defaults = {
    \ 'fdm': 'manual',
    \ 'ft': '',
    \ 'sts': 0,
    \ 'sw': 8,
    \ 'ts': 8,
	\ 'et': [ 0, {
		\ '0': 'noet',
		\ '1': 'et'
		\ } ]
    \ }

let s:sets = []

for [s:cfg, s:default] in items(s:defaults)
    " Poll the option value
    exe 'let s:rval=&' . s:cfg
	let s:_set = s:cfg . '=' . s:rval
	if type(s:default) == v:t_list
		let s:set = get(s:default[1], s:rval, s:_set)
		" Revert to scalar
		let s:default = s:default[0]
	else
		" Default setter
		let s:set = s:_set
	endif
    if s:rval != s:default
        call add(s:sets, s:set)
    endif
endfor

if len(s:sets) > 0
    " (&commentstring should be printf-compatible, e.g. "#%s")
    exe 'norm o'.substitute(printf(&commentstring, ' vi: ' . join(sort(s:sets))), ' \+', ' ', 'g')
endif

" vi: ft=vim
