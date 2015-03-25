" folding

" doesn't quite work
"setl foldexpr=(getline(v:lnum)=~'^diff\ ')?'<1':'1'

" makes things hard to navigate
"setl foldmethod=expr
"setl foldexpr=(getline(v:lnum)=~'^diff\ ')?'<1':(getline(v:lnum)=~'^@@\ ')?'1':'2'
