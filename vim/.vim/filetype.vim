" Only do this part when compiled with support for autocommands.

" Listen very carefully--I'm only going to say this once
if exists("did_load_my_filetypes")
  finish
endif
let did_load_my_filetypes=1

" automatic saving and loading of fold views, buffers, etc.
" addendum: evidently vim does this automatically?
"aug views
"	au!
"
"	" addendum: too bloated a solution; just save the line number as a jump
"	" position in ~/.viminfo:
"	au BufReadPost	*
"				\ if line("'\"") > 0 && line("'\"") <= line("$") |
"				\	exe "normal! g`\"" |
"				\ endif
"
"aug END " views

" slightly better fugitive + gitgutter integration
" (only makes life easier if g:gitgutter_realtime=0 and g:gitgutter_eager=0)
aug fugitive_gitgutter

	" leaving Fugitive staging buffer
	au BufLeave	index
				\ GitGutterAll

	" after Fugitive sends off a commit (probably unnecessary)
	au BufDelete	COMMIT_EDITMSG
				\ GitGutterAll

aug END " fugitive_gitgutter

aug keycommands
	au!

	" insert lorem ipsum text for all file types
	au BufNewFile,BufRead	*
				\ nnoremap <buffer> <silent> ,L :ru templates/keys/lorem_ipsum.vim<CR>

	" use backslash-pipe (or [num]-backslash-pipe) to quickly comment lines

	"" perl, sh, php and various config files use the # comment leader
	au FileType		alsaconf,coffee,conf,config,cvsrc,gitconfig,gtkrc,make,mplayerconf,muttrc,perl,php,procmail,python,readline,remind,resolv,screen,sh,squid,sshconfig,sudoers,yaml
				\ noremap <buffer> <silent> <leader>\| :s+^+#+\|nohls<CR>

	"" sql uses the -- comment leader
	au FileType		sql
				\ noremap <buffer> <silent> <leader>\| :s+^+--+\|nohls<CR>

	"" c variants use the // comment leader
	"" (technically, so does PHP, but I like to pretend I'm writing Perl)
	au FileType		c,java,javascript,scss
				\ noremap <buffer> <silent> <leader>\| :s+^+//+\|nohls<CR>

	"" vim uses the " comment leader
	au FileType		vim
				\ noremap <buffer> <silent> <leader>\| :s+^+"+\|nohls<CR>

	"" Xdefaults use the ! comment leader
	au FileType		xdefaults
				\ noremap <buffer> <silent> <leader>\| :s+^+!+\|nohls<CR>


	"" ini and [shudder] asm use the ; comment leader
	au FileType		asm,dosini
				\ noremap <buffer> <silent> <leader>\| :s+^+;+\|nohls<CR>

	" ,v - insertion of vim filetype specification
	au FileType		sh,perl,html,xml,c,cpp,conf,mplayerconf,vim
				\ nnoremap <buffer> <silent> ,v :ru templates/keys/hintline-filetype.vim<CR>

aug END " keycommands

" Transparent editing of gpg encrypted files.
" Placed Public Domain by Wouter Hanegraaff <wouter@blub.net>
aug encrypted
	au!

	" First make sure nothing is written to ~/.viminfo while editing
	" an encrypted file. We also don't want a swap file, as it writes
	" unencrypted data to disk.
	au BufReadPre,FileReadPre	*.gpg,*.asc
				\ setl vi= noswf

	" Switch to binary mode to read the encrypted file.
	au BufReadPre,FileReadPre,BufWritePre,FileWritePre	*.gpg
				\ setl bin

	" Decrypt the encrypted data in the buffer.
	au BufReadPost,FileReadPost	*.gpg,*.asc
				\ '[,']!sh -c 'gpg --decrypt 2>/dev/null'

	" Switch to normal mode for editing.
	au BufReadPost,FileReadPost,BufWritePost,FileWritePost	*.gpg
				\ setl nobin

	" Re-perform autocmds as if were editing the unencrypted file.
	au BufReadPost,FileReadPost	*.gpg,*.asc
				\ exe ':doau BufReadPost '.expand('%:rp')

	" Convert all text to encrypted text before writing.
	au BufWritePre,FileWritePre	*.gpg
				\ '[,']!gpg --default-recipient-self -e 2>/dev/null
	au BufWritePre,FileWritePre	*.asc
				\ '[,']!gpg --default-recipient-self -ae 2>/dev/null

	" Undo the encryption so we are back in the normal text, directly
	" after the file has been written.
	au BufWritePost,FileWritePost	*.gpg,*.asc
				\ u
aug END " encrypted

" Automatic header insertion for new source code files
aug sourcecode
	au!

	" perl
	au BufNewFile		*.pl
				\ ru templates/headers/perl.vim
	" perl modules
	au BufNewFile		*.pm
				\ ru templates/headers/perl-pm.vim

	" perl-CGI scripts
	au BufNewFile		*.cgi
				\ ru templates/headers/perl-cgi.vim

	" sh
	au BufNewFile		*.sh
				\ ru templates/headers/sh.vim

	" HTML
	au BufNewFile		*.html
				\ ru templates/headers/html5.vim

	" XML
	au BufNewFile		*.xml
				\ ru templates/headers/xml.vim

	"" XSLT
	au BufNewFile		*.xsl,*.xslt
				\ ru templates/headers/xsl.vim

	"" XSD
	au BufNewFile		*.xsd
				\ ru templates/headers/xsd.vim

	" Angular component templates
	au BufNewFile,BufRead	*.component.html
				\ setl et fdm=syntax ft=xml sts=4 sw=4 ts=4

aug END " sourcecode

" append compressors/decompressors to file pre-processing
aug gzipext

	" 7zip (not working)
	"au BufReadPre,FileReadPre	*.7z
	"			\ setlocal bin
	"au BufReadPost,FileReadPost	*.7z
	"			\ call gzip#read("7za x -so --")
	"au BufWritePost,FileWritePost	*.7z
	"			\ call gzip#write("7za a -si --")
	"au FileAppendPre		*.7z
	"			\ call gzip#appre("7za x -so --")
	"au FileAppendPost		*.7z
	"			\ call gzip#write("7za a -si --")

	"" archive support
	"au BufReadCmd			*.tar.7z,*.t7z
	"			\ call tar#Browse(expand("<amatch>"))

	" other ZIP-based archives
	"" *.odt	: OpenDocument text
	"" *.odm	: OpenDocument text
	au BufReadCmd			*.k3b,*.odt,*.odm,*.epub,*.pk3
				\ call zip#Browse(expand("<amatch>"))

aug END " gzipext

" vi: ft=vim fdm=syntax
