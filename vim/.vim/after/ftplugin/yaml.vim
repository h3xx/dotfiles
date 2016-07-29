" example formatting:
"
"- key: Parent
"  url: http://www.example.com/
"  list:
"  - foo
"  - bar
"  - baz
"  child_list:
"  - key: Child
"    url: http://www.example.com/
"    list:
"    - foo
"    - bar
"  - key: Child2
"    url: http://www.example.com/
"    list:
"    - baz
"    - qux
setl ts=2 sts=2 sw=2

" G2Planet customizations

" search ClassName.php when doing `gf'
setl suffixesadd=.php

setl path=.
setl path+=..
setl path+=../..
setl path+=../templates
setl path+=../utility
setl path+=../page
setl path+=../eclib/page
setl path+=../eclib/database
setl path+=../eclib/templates
setl path+=../../eclib/page
setl path+=../../eclib/database
setl path+=../../eclib/templates
setl path+=../emaxlib/page
setl path+=../emaxlib/database
setl path+=../../emaxlib/page
setl path+=../../emaxlib/database
setl path+=../eventlib/database
setl path+=../eventlib/page
setl path+=../../eventlib/database
setl path+=../../eventlib/page
" current dir
setl path+=
