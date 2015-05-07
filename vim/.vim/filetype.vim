" Only do this part when compiled with support for autocommands.

" Listen very carefully--I'm only going to say this once
if exists("did_load_my_filetypes")
  finish
endif
let did_load_my_filetypes=1

" This keeps getting set wrong for some reason
"au BufNew			*	setl fo-=ot

" automatic saving and loading of fold views, buffers, etc.
aug views
	au!

	" * do not save/load views for empty files
	" * do not save views for diffs as this sets a whole bunch of options
	"   that make it hard to work with when it's opened as a non-diff
"	au BufWinLeave	*	if expand("%") != "" && ! &diff |
"				\ mkview |
"				\ endif
"	au BufWinEnter	*	if expand("%") != "" |
"				\ silent loadview |
"				\ endif

	" addendum: too bloated a solution; just save the line number as a jump
	" position in ~/.viminfo:
	au BufReadPost	*
				\ if line("'\"") > 0 && line("'\"") <= line("$") |
				\	exe "normal! g`\"" |
				\ endif

aug END " views

" XXX : this is now handled via ~/.vim/ftdetect/*.vim
"aug filetypedetect
"	au!
"
"	" warning: detects vim help files as 'text'
"	" addendum: this is more trouble than it's worth
"	au BufNewFile,BufRead	*.txt
"				\ if &ft == "" |
"				\	setf text |
"				\ endif
"
"aug END " filetypedetect

" set up some quick filetype-based options
aug filetypeoptions
	au!

	" needed for perldoc integration
	au FileType		perl
				\ let g:perldoc_program='perldoc' |
				\ nmap <buffer> <silent> <F2> :Perldoc<CR>

	" spell	- use spell checking
	" scs	- use smart case checking (for searching, assume /i flag
	"	  unless pattern has an uppercase letter in it)
	" nojs	- don't insert two spaces after a period when j-ing or gq-ing
	au FileType		text,mail
				\ setl spell scs fo+=t fo-=r

	" undo the settings on vim help files and CMake*.txt (detected above as
	" 'text')
	" addendum: not necessary anymore
"	au FileType		help,cmake
"				\ setl nospell noscs

aug END " filetypeoptions

aug keycommands
	au!

	" insert lorem ipsum text for all file types
	au BufNewFile,BufRead	*
				\ nnoremap <buffer> <silent> ,L :so ~/.vim/templates/keys/lorem_ipsum.vim<CR>

	" use backslash-pipe (or [num]-backslash-pipe) to quickly comment lines

	"" perl, sh, php and various config files use the # comment leader
	au FileType		alsaconf,coffee,conf,config,cvsrc,gitconfig,gtkrc,make,mplayerconf,muttrc,perl,php,procmail,python,readline,remind,resolv,screen,sh,squid,sshconfig,sudoers,yaml
				\ noremap <buffer> <silent> <leader>\| :s+^+#+\|nohls<CR>

	"" sql uses the -- comment leader
	au FileType		sql
				\ noremap <buffer> <silent> <leader>\| :s+^+--+\|nohls<CR>

	"" c, javascript and java use the // comment leader
	"" (technically, so does PHP, but I like to pretend I'm writing Perl)
	au FileType		c,java,javascript
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

	" web functions
	" ,h - insert HTML header in HTML files
	au FileType		html
				\ nmap <buffer> <silent> ,h :so ~/.vim/templates/keys/html5-h.vim<CR> |
				\ nmap <buffer> <silent> ,j :so ~/.vim/templates/keys/html5-j.vim<CR>

	" ,h - insert XML header in XML files (though it's already inserted
	"      upon BufNewFile)
	au FileType		xml
				\ nmap <buffer> <silent> ,h :so ~/.vim/templates/keys/xml-h.vim<CR>

	" Perl debugging functions
	" ,d - insert Data::Dumper call
	" ,g - insert Getopt::Std option processing
	au FileType		perl
				\ nmap <buffer> <silent> ,d :so ~/.vim/templates/keys/perl-d.vim<CR> |
				\ nmap <buffer> <silent> ,g :so ~/.vim/templates/keys/perl-g.vim<CR>

	" Shell functions
	" ,g - insert getopts processing block
	" ,t - insert call to mktemp(1)
	" ,T - insert shell-script cleanup code that uses trap
	au FileType		sh
				\ nmap <buffer> <silent> ,g :so ~/.vim/templates/keys/sh-getopts.vim<CR> |
				\ nmap <buffer> <silent> ,t :so ~/.vim/templates/keys/sh-mktemp.vim<CR> |
				\ nmap <buffer> <silent> ,T :so ~/.vim/templates/keys/sh-trap-cleanup.vim<CR> |
				\ nmap <buffer> <silent> ,Z :so ~/.vim/templates/keys/sh-help_message.vim<CR>

	" ,v - insertion of vim filetype specification
	au FileType		sh,perl,html,xml,c,cpp,conf,mplayerconf,vim
				\ nnoremap <buffer> <silent> ,v :so ~/.vim/templates/keys/hintline-filetype.vim<CR>

	" ,h - insert <?php header in php files
	" ,E - throw new Exception
	" ,c - insert filename (without .php), useful for class files
	au FileType		php
				\ nmap <buffer> <silent> ,h :so ~/.vim/templates/keys/php-h.vim<CR> |
				\ nmap <buffer> <silent> ,E :so ~/.vim/templates/keys/php-E.vim<CR> |
				\ nmap <buffer> <silent> ,c :so ~/.vim/templates/keys/php-c.vim<CR>

	" build script build files
	" ,h - insert header file from /tmp/svn/_configure/__header
	" ,s - insert command for writing slack-desc
	" ,f - insert finisher file from /tmp/svn/_configure/__finisher
	au BufNewFile,BufRead	*/_configure/*-build,*/build/scripts/*-build
				\ nmap <buffer> <silent> ,h :so ~/.vim/templates/keys/_configure-h.vim<CR> |
				\ nmap <buffer> <silent> ,H :so ~/.vim/templates/keys/_configure-H.vim<CR> |
				\ nmap <buffer> <silent> ,s :so ~/.vim/templates/keys/_configure-s.vim<CR> |
				\ nmap <buffer> <silent> ,f :r /tmp/svn/_configure/__finisher<CR>
	au BufNewFile,BufRead	*/_configure/*,*/build/scripts/*
				\ nmap <buffer> <silent> ,p :so ~/.vim/templates/keys/_configure-p.vim<CR> |
				\ nmap <buffer> <silent> ,l :so ~/.vim/templates/keys/_configure-l.vim<CR> |
				\ nmap <buffer> <silent> ,d :so ~/.vim/templates/keys/_configure-d.vim<CR>

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
				\ so ~/.vim/templates/headers/perl.vim
	" perl modules
	au BufNewFile		*.pm
				\ so ~/.vim/templates/headers/perl-pm.vim

	" perl-CGI scripts
	au BufNewFile		*.cgi
				\ so ~/.vim/templates/headers/perl-cgi.vim

	" sh
	au BufNewFile		*.sh
				\ so ~/.vim/templates/headers/sh.vim

	" XML
	au BufNewFile		*.xml
				\ so ~/.vim/templates/headers/xml.vim

	"" XSLT
	au BufNewFile		*.xsl,*.xslt
				\ so ~/.vim/templates/headers/xsl.vim

	"" XSD
	au BufNewFile		*.xsd
				\ so ~/.vim/templates/headers/xsd.vim

	" scilab (not really applicable anymore)
	"au BufNewFile		*.sci
	"			\ exe 'norm afunction '.expand('%:t:r').'()\nendfunction\<esc>O// FIXME: description stub\n\n// Arguments:\n//\tFIXME: arguments stub\n//\n// Returns FIXME: return stub\n//!\n\<esc>'

	" It's All Text! (Firefox plugin)
	"" Waffles.fm description text (last line inserts `Track listing'
	"" header and `Source:' footer)
	au BufNewFile		waffles.fm*,*/waffles/*.txt
				\ exe "norm o[size=3][b]Track listing[/b][/size]\r\rSource: [url=][/url]\<esc>gg"

aug END " sourcecode

" Use vim as a hex editor
" (this gets really annoying when trying to edit files with a .dat extension;
" should look into setting it up as a filetype)
"aug binary
"	au!
"
"	" Switch to binary mode to read the file
"	au BufReadPre,FileReadPre	*.dat
"				\ setl bin
"
"	" Perform a hex dump when opening OR refresh hex dump with new
"	" file contents after writing
"	au BufReadPost,FileReadPost,BufWritePost,FileWritePost	*.dat
"				\ '[,']!xxd
"
"	" Switch to normal mode for editing
"	au BufReadPost,FileReadPost	*.dat
"				\ setl ft=xxd nobin
"
"	" Revert hex dump to binary data before writing
"	au BufWritePre,FileWritePre	*.dat
"				\ '[,']!xxd -r
"
"aug END " binary

" Files that should not have FILENAME~ backups saved
" (addendum: this is more efficiently defined in the vimrc using the
" `backupskip' [alias `bsk'] variable)
"aug nobackups
	"au!

	" Don't backup files used in building Slackware packages.
	"au BufNewFile,BufRead	*/install/slack-desc,*/install/doinst.sh,*/install/slack-required,*/install/slack-suggests
	"				\ setl nobk

	" Don't backup cron scripts (or they'll run twice)
	"au BufNewFile,BufRead	*/.cron/*/*
	"				\ setl nobk

	" Create .orig backups for scripts.
	"au BufNewFile,BufRead	*/bin/*		setl pm=".orig"

"aug END " nobackups

" append compressors/decompressors to file pre-processing
aug gzipext

	" xz-utils (already implemented in system Vim)
	"au BufReadPre,FileReadPre	*.xz
	"			\ setlocal bin
	"au BufReadPost,FileReadPost	*.xz
	"			\ call gzip#read("xz -d")
	"au BufWritePost,FileWritePost	*.xz
	"			\ call gzip#write("xz")
	"au FileAppendPre		*.xz
	"			\ call gzip#appre("xzcat")
	"au FileAppendPost		*.xz
	"			\ call gzip#write("xz")

	"" archive support
	"au BufReadCmd			*.tar.xz,*.txz
	"			\ call tar#Browse(expand("<amatch>"))

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
	"" *.egg	: Python egg-based distribution
	"" *.jpa	: JPF plug-ins archive
	"" *.odt	: OpenDocument text
	"" *.odm	: OpenDocument text
	au BufReadCmd			*.egg,*.jpa,*.k3b,*.odt,*.odm,*.epub
				\ call zip#Browse(expand("<amatch>"))

aug END " gzipext

" vi: ft=vim fdm=syntax
