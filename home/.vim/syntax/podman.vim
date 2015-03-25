" Vim syntax file

" Maintainer:	Colin Keith <vim@ckeith.clara.net>
" Last Change:	2002 Jan 24

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

hi link podmanSubSectTitle String
hi link podmanSectTitle	Statement
hi link podmanText      Normal
hi link podmanExample   Comment

" POD commands
syn match podmanSectTitle    "^[A-Z][A-Z -]\+"
syn match podmanSubSectTitle "^  [^ ].*$"
syn match podmanText         "^    [^ ].\+$"
syn match podmanExample      "^      .\+"
