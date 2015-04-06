Perldoc.vim v1.1
----------------

The Perldoc.vim plugin is a command + function that enables the perldoc command
to be used from within the Vim text editor. This can be useful for Perl
coders as it enables them to be able to work with a Perl program whilst
having the corresponding documentation open in front of them at the same
time.

When activated the Perldoc command opens a new window at the top of the
screen and places the output of the perldoc command into that window. This
read-only window is just a Vim window, so you can perform all of the normal
commands that you can in Vim - such as searching for a word or expression,
yanking examples and code snippets.


The zip file also comes with a simple set of highlighting rules for the
perldoc output. This was added as I was going blind staring at the
monochrome foreground colour (green for me :) when I was so used to Vim's
wonderful syntax highlighting. Oh yeah er.. and it makes it easier to find
things thus increasing productivity and such things (in case your boss asks
:)


How does it work?
-----------------

This ftplugin works by parsing the contents of the line on which the cursor
resides for ways of including Perl modules. Most commonly seen is "use",
but it also parses lines with "require" as well. It will do its best to
extract the appropriate file/module name from the code and perform the
command

  perldoc -U "docname"

So if your code has the lines:

  use strict;
  use warnings;
  use Net::FTP;
  require "Net/FTP.pm";

Place your cursor on any of these lines and enter the command

  :Perldoc

And it will bring up the appropriate documentation. If you want to check
some document you don't have installed, 'perlfunc' or 'perlipc' perhaps,
then you can use the same command by entering:

  :Perldoc <pod page>

I.e.

  :Perldoc perlfunc


INSTALL
-------

To use this program its now much simplier than last time. You can use it in
one of two ways. In both cases you need to:

  * Copy the podman.vim  file to your personal syntax directory.
  * Copy the perl_doc.txt file in your personal doc directory.

  [ User directories are show on your runtimepath (:help rtp), but are
    often places such as  $HOME/.vim/syntax/ or c:\vim\vimfiles\syntax\ ]

  Then copy the core of the program according to either of the following:

 1) As a Filetype Plugin (FTPlugin)

   These are plugins for specific filetypes and contain commands for only
   one filetype. They do not include personal preferences such as
   shiftwidth, but settings specific to that filetype such as keywords,
   error formats, etc. To use this module as a ftplugin you must:

   * Enable filetype plugins using the command:

         :filetype plugin on					|filetype-plugin-on|

   * Copy the perl_doc.vim file to your personal ftplugin directory:

          unix% cp perl_doc.vim $HOME/.vim/ftplugin/perl_doc.vim

     or

          C:\>  copy perl_doc.vim c:\vim\vimfiles\ftplugin\perl_doc.vim

 2) As a normal file with Vim commands:
    There is no specifi location for such files so you may wish to place
    the file outside of the 'runtimepath' to prevent any clashes. Then
    use the following autocmd (|+autocmd|) to enable it for Perl filetypes
    only:

          au FileType perl source <location of perl_doc.vim>

  In both cases, once you have installed the plugin documentation you
  should add it to your tags file by starting Vim and issuing the command:

    :helptags <your_local_docs_dir>				|add-local-help|

  If your perldoc program is not in the default location then you should
  define it for the function using the 'g:perldoc_program' variable. Of
  course this variable is only used by this function, and this function is
  only loaded when the filetype is Perl, so you may wish to use an autocmd
  to set the value for this variable only when the filetype is set to Perl.
  (Okay, strictly speaking it only sets it and never unsets it, but...)
  I.e.

    au FileType perl let g:perldoc_program='/usr/local/bin/perldoc'



CHANGES
-------

 v1.1 => v1.1.1

 * -U flag is only used it perl v5.6x implimentations, removed from default
   and turned into a g:perldoc_flags variable. It will try to use a reasonable
   default based on the version of Perl.

 v1.0 => v1.1

After learning some more about Vim I've come to realise that I screwed up
quite a bit so here are some of the changes:

 * Installation is easier, no more useless filenames like "perl.vim" in the
   wrong place. This is now a (FileType) Plugin with full documentation.
 * Proper file headers.
 * Added -buffer to command
 * Converted "set" to "setlocal"
 * Added nomodified to POD window pages.
 * Switched from su -c " ... " to using "perldoc -U"
   and thus removed all the code for 'whoami' searches.
 * Corrected erroneous 'finish' to a 'return' when the Perldoc command
   wasn't found or wasn't executable.
 * Removed g:loaded_pdp notation. We now just check for the presence of the
   Perldoc command. Uses b:did_ftplugin notation for the entire file instead.
 * If g:perldoc_program is defined, but not executable, falls back to the
   built-in defaults (which differ on win32 and others). If the defaults
   aren't executable then it errors as normal.
 * Window height is calculated just before opening the window, not outside
   and passed as a variable to the Perldoc() function. Also height is now a
   script variable s:height.
 * Expanded iskeyword support given by default Perl ftplugin to include .
   and / that could be used in 'requires'.
 * Now sets the 'keywordprg' variable to "perldoc". The first time the
   Perldoc program is executed (be it the value of g:perldoc_command or one
   of the system defaults), keywordprg is updated to use this value to make
   it mildly more secure than "any program called perldoc"


Help
----

Hopefully this document will clarify some of the problems I caused by being
clueless about where to place files in Vim. Contact the author if you have
any problems or questions (or suggestions, or just want to offer exotic
jobs on wealthy tropical islands ... :)

Author
------
 Colin Keith <vim@ckeith.clara.net>
