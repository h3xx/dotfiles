" fold the header
setl foldmethod=expr foldexpr=getline(v:lnum)=~'^\"' foldlevel=0

" (syntax method, doesn't quite work because I'm a n00b)
"syn region foldNetrwComment start=/"\ =\+/ end=/"\ =\+/ transparent fold keepend
