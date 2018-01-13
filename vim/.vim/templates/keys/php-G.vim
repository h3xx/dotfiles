" macro for generating a getter/setter

" Turns this:
"
"	class foo {
"		\PDO database|
"	}
"
" Into this:
"
"	class foo {
"	    private $database;
"
"	    public function setDatabase(\PDO $database): self {
"	        $this->database = $database;
"	        return $this;
"	    }
"
"	    private function getDatabase(): \PDO {
"	        return $this->database;
"	    }
"   }

" duplicate the line
yank

" private member
s,^\(\s*\)\(\S\+\)\(\s*\)\(\S\+\),\1private $\4;\r,

" setter
put
s,^\(\s*\)\(\S\+\)\(\s*\)\(\S\+\),\1public function set\u\4(\2 $\4): self {\r$this->\4 = $\4;\rreturn $this;\r}\r,

" getter
put
s,^\(\s*\)\(\S\+\)\(\s*\)\(\S\+\),\1private function get\u\4(): \2 {\rreturn $this->\4;\r}\r,

" indent the abomination
norm =8k

" turn off search highlighting
noh
