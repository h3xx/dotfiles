"=============================================================================
" File:        ide.vim
" Author:      Daniel Gomez-Prado (http://dgomezpr.com)
" Last change: Dec 18 2012, 10:48:49 PM EST
" Version:     0.4.4
" Changes:     type ':help ide' and click on |ide-changes|
" Todo:        type ':help ide' and click on |ide-todo|
" Bugs:        type ':help ide' and click on |ide-bug|
"=============================================================================
" The ide.vim plugin is based on the project.vim plugin developed by
" Aric Blumer version 1.4.1, last changed on Fri 13 Oct 2006 09:47:08
"=============================================================================
" See documentation in accompanying help file
" You may use this code in whatever way you see fit.
"
"NOTES:
" Each buffer has a unique number and that number will not change in a Vim session
"  <-1,N> = winbufnr(<window>)
"           the number of the buffer associated with <window>.
"           <window> 0 = current window
"  <-1,N> = bufwinnr(<buffer>)
"         =  the number of the first window associated with <buffer>
"  <-1,N> = bufnr(<buffer>)
" 			the number of a buffer, as it is displayed by the ":ls" command
" 			<buffer> $ = current buffer
"  string = bufname(file_pattern_buffer_name)
"  string = bufname(buffer_number)
"  			The result is the name of a buffer, as it is displayed by the ":ls"
"

"==== Tab Movements ==================================================================
if (v:version >= 700)
	" === DoMove2LeftTab() ===================================================<<<
	function! s:DoMove2LeftTab()
		if !exists('g:IDE_Title') || bufwinnr(g:IDE_Title) == -1
			exe 'tabprevious'
		else
			" 1 == bufwinnr(g:IDE_Title) |==> the window is open
			let save_winnr = winnr()
			call s:IDE_GainFocusIfOpenInWindows()
			call s:IDE_ToggleClose()
			exe 'tabprevious'
			if bufwinnr(g:IDE_Title) == -1
				call s:IDE_ToggleOpen()
				call s:DoWindowSetupAndSplit()
			endif
			if save_winnr != winnr()
				call s:IDE_ExeWithoutAucmds(save_winnr . 'wincmd w')
			endif
		endif
	endfunction
	">>>
	" === DoMove2NextTab() ===================================================<<<
	function! s:DoMove2RightTab()
		if !exists('g:IDE_Title') || bufwinnr(g:IDE_Title) == -1
			exe 'tabnext'
		else
			" 1 == bufwinnr(g:IDE_Title) |==> the window is open
			let save_winnr = winnr()
			call s:IDE_GainFocusIfOpenInWindows()
			call s:IDE_ToggleClose()
			exe 'tabnext'
			if bufwinnr(g:IDE_Title) == -1
				call s:IDE_ToggleOpen()
				call s:DoWindowSetupAndSplit()
			endif
			if save_winnr != winnr()
				call s:IDE_ExeWithoutAucmds(save_winnr . 'wincmd w')
			endif
		endif
	endfunction
	">>>
endif
"================ Script Initialization ==============================================
" === First time load of the Project plugin ==============================<<<
let s:cpo_save = &cpoptions
set cpoptions&vim
if !exists('g:IDE_isLoaded')
	" === setup variables if they don't already exist to a default value ====<<<
	function s:Set(variable, default)
		if !exists(a:variable)
			if type(a:default)
				exe "let" a:variable "=" string(a:default)
			else
				exe "let" a:variable "=" a:default
			endif
			return 1
		endif
		return 0
	endfunction
	">>>
	" === setup flags =======================================================<<<
	function! s:SetupVariablesFromFlag(condition,variable)
		if exists(a:variable)
			call s:IDE_ErrorMsg("variable ".a:variable." it already exists")
			return 0
		endif
		if a:condition == 1
			exe "let ".a:variable." = ".1
		else
			exe "let ".a:variable." = ".0
		endif
	endfunction
	" >>>
	" === check if the fils is on path ======================================<<<
	function! s:pathHasFile(path,file)
		let l:file_if_found = ''
		if has('file_in_path')
			let l:file_if_found=findfile(a:file,a:path)
		else
			let l:file_if_found=a:path.'/'.a:file
			let l:file_if_found=s:IDE_GetConsistentFileName(l:file_if_found)
			if !filereadable(s:l:file_if_found)
				let l:file_if_found = ''
			endif
		endif
		return l:file_if_found
	endfunction
	">>>
	" === Process Project flags =============================================<<<
	"all flags are +bcfFgiLmMRsStTuv
	if has('win32') || has('win64') || has('mac')
		call s:Set('g:IDE_ProjectFlags','imst')
		call s:Set('g:IDE_AdvancedFlags','')
	else
		"let g:IDE_ProjectFlags='imstb'
		call s:Set('g:IDE_ProjectFlags','gimsSt')
		call s:Set('g:IDE_AdvancedFlags','fMOSTz')
	endif

	"The Advanced Flags are the new flags from ide.vim:    +fCDMoORSTu
	"                                 deprecated flags:
	call s:SetupVariablesFromFlag( (match(g:IDE_AdvancedFlags, '\C+') != -1), "s:IDE_isEnableFoldColumn")
	call s:SetupVariablesFromFlag( (match(g:IDE_AdvancedFlags, '\CC') != -1), "s:IDE_isSortWithCase")
	call s:SetupVariablesFromFlag( (match(g:IDE_AdvancedFlags, '\CD') != -1) && has('digraphs'), "s:IDE_useDigraphs")
	call s:SetupVariablesFromFlag( (match(g:IDE_AdvancedFlags, '\Cf') != -1), "s:IDE_isGainFocusOnToggle")
	call s:SetupVariablesFromFlag( (match(g:IDE_AdvancedFlags, '\CM') != -1), "s:IDE_hasMapMake")
	call s:SetupVariablesFromFlag( ((match(g:IDE_AdvancedFlags,'\Co') != -1 || match(g:IDE_AdvancedFlags, '\CO') != -1) && has('signs')), "s:IDE_isEnableSignMarks")
	call s:SetupVariablesFromFlag( (match(g:IDE_AdvancedFlags, '\CO') != -1 && has('signs')), "s:IDE_isEnableSignMarksClose")
	call s:SetupVariablesFromFlag( (match(g:IDE_AdvancedFlags, '\CR') != -1), "s:IDE_isAtRightWindow")
	call s:SetupVariablesFromFlag( (match(g:IDE_AdvancedFlags, '\CS') != -1 && has('syntax')  && exists('g:syntax_on')), "s:IDE_isSyntaxCapable")
	call s:SetupVariablesFromFlag( (match(g:IDE_AdvancedFlags, '\CT') != -1) && (v:version >= 700), "s:IDE_hasMapTabMove")
	call s:SetupVariablesFromFlag( (match(g:IDE_AdvancedFlags, '\Cu') != -1), "s:IDE_updateWinManagerAlways")
	call s:SetupVariablesFromFlag( (match(g:IDE_AdvancedFlags, '\Cz') != -1), "s:IDE_foldProjectEntries")
	"The Project Flags are the previous flags from project.vim:    bcFgilLmnsStTv
	"                                         deprecated flags:      F  l m
	call s:SetupVariablesFromFlag( (match(g:IDE_ProjectFlags, '\Cb') != -1 && has('browse') && !has('win32')), "s:IDE_isUsingBrowse")
	call s:SetupVariablesFromFlag( (match(g:IDE_ProjectFlags, '\Cc') != -1), "s:IDE_isCloseOnOpen")
	call s:SetupVariablesFromFlag( (match(g:IDE_ProjectFlags, '\CF') != -1), "s:IDE_isFloating")
	call s:SetupVariablesFromFlag( (match(g:IDE_ProjectFlags, '\Cg') != -1), "s:IDE_hasMapToggle")
	call s:SetupVariablesFromFlag( (match(g:IDE_ProjectFlags, '\Ci') != -1), "s:IDE_isShowingInfo")
	call s:SetupVariablesFromFlag( (match(g:IDE_ProjectFlags, '\CL') != -1), "s:IDE_isChangingCWD")
	call s:SetupVariablesFromFlag( (match(g:IDE_ProjectFlags, '\Cn') != -1), "s:IDE_isShowLineNumber")
	call s:SetupVariablesFromFlag( (match(g:IDE_ProjectFlags, '\Cs') != -1 && has('syntax') && exists('g:syntax_on') && !has('syntax_items')), "s:IDE_doSyntaxOnWindowIDE")
	call s:SetupVariablesFromFlag( (match(g:IDE_ProjectFlags, '\CS') != -1), "s:IDE_isSortingOn")
	call s:SetupVariablesFromFlag( (match(g:IDE_ProjectFlags, '\Ct') != -1), "s:IDE_isToggleSize")
	call s:SetupVariablesFromFlag( (match(g:IDE_ProjectFlags, '\CT') != -1), "s:IDE_isSubProjectToTop")
	call s:SetupVariablesFromFlag( (match(g:IDE_ProjectFlags, '\Cv') != -1), "s:IDE_isVimGrep")
	" TODO deprecate the following options: mnl
	" do not assign any new functionality to this letters to be backward compatible
	" %%%% implement it on always 1 with a spin, current is not the IDE buffer, but the open file, or selected file

	">>>
	" === Define global default settings and maps ===========================<<<
	"if not already defined, then define default values
	if (s:IDE_useDigraphs)
		call s:Set("g:IDE_Divider",'■■■■')
	else
		call s:Set("g:IDE_Divider",'%%%%')
	endif
	call s:Set("g:IDE_UpdateSyntaxAt",'10%')
	call s:Set("g:IDE_WindowWidth",24)
	call s:Set("g:IDE_WindowIncrement",50)
	if (v:version >= 700)
		call s:Set("g:IDE_DefaultOpenMethod",'tabe')
		call s:Set("g:IDE_ShiftOpenMethod",'sp')
	else
		call s:Set("g:IDE_DefaultOpenMethod",'sp')
		call s:Set("g:IDE_ShiftOpenMethod",'sp')
	endif
	if s:IDE_hasMapTabMove
		call s:Set("g:IDE_MapMove2RightTab",'<C-Right>')
		call s:Set("g:IDE_MapMove2LeftTab",'<C-Left>')
	endif
	if s:IDE_hasMapToggle
		call s:Set("g:IDE_MapProjectToggle",'<F12>')
	endif
	if s:IDE_hasMapMake
		call s:Set("g:IDE_MapMakeMainTarget_1",'<F7>r')
		call s:Set("g:IDE_MapMakeMainTarget_2",'<F7>d')
		call s:Set("g:IDE_MapMakeMainTarget_3",'<F7>c')
		call s:Set("g:IDE_MapMakeThisTarget_1",'<C-F7>r')
		call s:Set("g:IDE_MapMakeThisTarget_2",'<C-F7>d')
		call s:Set("g:IDE_MapMakeThisTarget_3",'<C-F7>c')
		call s:Set("g:IDE_MainTarget_1",'')
		call s:Set("g:IDE_MainTarget_2",'debug')
		call s:Set("g:IDE_MainTarget_3",'clean')
		call s:Set("g:IDE_ThisTarget_1",'')
		call s:Set("g:IDE_ThisTarget_2",'debug')
		call s:Set("g:IDE_ThisTarget_3",'clean')
	endif
	call s:Set("g:IDE_Info",'<LocalLeader>i')
	call s:Set("g:IDE_InfoDetailed",'<LocalLeader>I')
	call s:Set("g:IDE_LoadAll",'<LocalLeader>l')
	call s:Set("g:IDE_LoadAllRecursive",'<LocalLeader>L')
	call s:Set("g:IDE_WipeAll",'<LocalLeader>w')
	call s:Set("g:IDE_WipeAllRecursive",'<LocalLeader>W')
	call s:Set("g:IDE_GrepAll",'<LocalLeader>g')
	call s:Set("g:IDE_GrepAllRecursive",'<LocalLeader>G')
	call s:Set("g:IDE_Create",'<LocalLeader>c')
	call s:Set("g:IDE_CreateRecursive",'<LocalLeader>C')
	call s:Set("g:IDE_RefreshContent",'<LocalLeader>r')
	call s:Set("g:IDE_RefreshContentRecursive",'<LocalLeader>R')
	call s:Set("g:IDE_SortContent",'<LocalLeader>s')
	call s:Set("g:IDE_SortContentRecursive",'<LocalLeader>S')
	call s:Set("g:IDE_FetchInProjectRecursive",'<Leader>f')
	call s:Set("g:IDE_FetchInAllProjects",'<Leader>F')
	if !exists("g:IDE_MakefileList")
		let g:IDE_MakefileList = [ "makefile" , "Makefile" ]
	endif
	if has('win32') || has('win64') || has('mac')
		call s:Set("g:IDE_IconFolder",'vimfiles/icons')
	else
		call s:Set("g:IDE_IconFolder",'~/.vim/icons')
 	endif
	call s:Set("g:IDE_syntaxScript",'ideSyntax.pl')
	">>>
	" === Constant variables for the script =================================<<<
	" do NOT modify this, they must remain constant through out the session
	let s:IDE_cmdCd = 'lcd'
	if s:IDE_isAtRightWindow
		" Open the window at the rightmost place
		let s:IDE_cmdLocate = 'silent! wincmd L'
		let s:IDE_cmdWindowPlace = 'botright vertical'
		let s:IDE_cmd2WindowFar = 'silent! wincmd H'
		let s:IDE_cmd2WindowSide = 'silent! wincmd h'
	else
		" Open the window at the leftmost place
		let s:IDE_cmdWindowPlace = 'topleft vertical'
		let s:IDE_cmd2WindowFar = 'silent! wincmd L'
		let s:IDE_cmd2WindowSide = 'silent! wincmd l'
		let s:IDE_cmdLocate = 'silent! wincmd H'
	endif
	"let s:IDE_cmdResize='vertical resize '
	let s:brief_help_size = 2
	let s:full_help_size = 15
	if s:IDE_hasMapMake
		let s:full_help_size +=6
	endif
	if s:IDE_hasMapToggle
		let s:full_help_size +=1
	endif
	if (has('win32') || has('win64')) && !has('gui_running')
		let s:IDE_isResizable = 0
	else
		let s:IDE_isResizable = 1
	endif
	let s:IDE_isDebugging = 0
	let s:IDE_DumpDebugToFile = 0
	let s:IDE_DebugFile = expand("~/ide.debug")
	let s:IDE_Divider = g:IDE_Divider
	let s:divw = 5
	while ( s:divw > 0 )
		let s:IDE_Divider .= s:IDE_Divider
		let s:divw -= 1
	endwhile
	let s:IDE_syntaxScript = "ideSyntax.pl"
	let s:IDE_existSyntaxScript=1
	if has("win32") || has("win64")
		let s:IDE_cmdCopy = "copy"
		let s:IDE_cmdDelFile = "delete"
		let s:IDE_PluginFolder = expand("$VIM"). "/vimfiles/plugin/"
		let s:IDE_SyntaxScriptFile = s:pathHasFile(s:IDE_PluginFolder,s:IDE_syntaxScript)
		if(s:IDE_SyntaxScriptFile=='')
			let s:IDE_PluginFolder = expand('$HOME') . "/vimfiles/plugin/"
			let s:IDE_SyntaxScriptFile = s:pathHasFile(s:IDE_PluginFolder,s:IDE_syntaxScript)
		endif
	else
		let s:IDE_cmdCopy = "cp"
		let s:IDE_cmdDelFile = "rm"
		let s:IDE_PluginFolder = expand('$HOME') . "/.vim/plugin/"
		let s:IDE_SyntaxScriptFile = s:pathHasFile(s:IDE_PluginFolder,s:IDE_syntaxScript)
	endif
	if(s:IDE_SyntaxScriptFile=='')
		let s:IDE_existSyntaxScript=0
	endif
	">>>
	" === Define the user commands to manage the IDE window =================<<<
	command! -nargs=* -complete=file IDE call s:IDE_Load(<q-args>)
	cabbrev ide <c-R>=((getcmdtype()==':' && getcmdpos()==1) ? 'IDE' : 'ide')<cr>
	" Trick to get the current script ID
	map <SID>xx <SID>xx
	let s:IDE_sid = substitute(maparg('<SID>xx'), '<SNR>\(\d\+_\)xx$', '\1', '')
	unmap <SID>xx
	exe 'autocmd FuncUndefined *' . s:IDE_sid . 'IDE_* source ' .  escape(expand('<sfile>'), ' ')
	"exe 'autocmd FuncUndefined *' . s:IDE_sid . 'IDE_window_* source ' . escape(expand('<sfile>'), ' ')
	"exe 'autocmd FuncUndefined *' . s:IDE_sid . 'IDE_menu_* source ' . escape(expand('<sfile>'), ' ')
	"exe 'autocmd FuncUndefined IDE_* source ' . escape(expand('<sfile>'), ' ')
	exe 'autocmd FuncUndefined IDE_* source ' . escape(expand('<sfile>'), ' ')
	">>>
	let g:IDE_isLoaded="base_load_done"
	" === Highlight groups for IDE ==========================================<<<
	hi default IDEHL_Folded cterm=bold guifg=white guibg=darkRed
	hi default IDEHL_Divider gui=bold guifg=black guibg=black
	hi default IDEHL_Help gui=bold guifg=SeaGreen
	hi default IDEHL_HelpType guifg=White guibg=DarkBlue
	hi default IDEHL_FileOpen gui=bold guifg=white guibg=DarkCyan
	hi default IDEHL_FileEdit gui=bold guifg=white guibg=DarkRed
	hi default IDEHL_FileReadOnly gui=bold guifg=DarkRed guibg=Grey
	hi default IDEHL_FileClose gui=bold guifg=black guibg=Grey
	">>>
	" === Sign symbols ======================================================<<<
	if s:IDE_isEnableSignMarks
		let s:IDE_IconOpen = expand(g:IDE_IconFolder.'/ideOpen.png')
		let s:IDE_IconEdit = expand(g:IDE_IconFolder.'/ideEdit.png')
		let s:IDE_IconReadOnly = expand(g:IDE_IconFolder.'/ideReadOnly.png')
		let s:IDE_IconClose = expand(g:IDE_IconFolder.'/ideClose.png')
		let s:iconOpen = ''
		let s:iconEdit = ''
		let s:iconReadOnly = ''
		let s:iconClose = ''
		if filereadable(s:IDE_IconOpen)
			let s:iconOpen = ' icon='. escape(s:IDE_IconOpen, '| \')
		endif
		if filereadable(s:IDE_IconEdit)
			let s:iconEdit = ' icon='. escape(s:IDE_IconEdit, '| \')
		endif
		if filereadable(s:IDE_IconReadOnly)
			let s:iconReadOnly = ' icon='. escape(s:IDE_IconReadOnly, '| \')
		endif
		if filereadable(s:IDE_IconClose)
			let s:iconClose = ' icon='. escape(s:IDE_IconClose, '| \')
		endif

		"                IDEsign0 refers to a file never viewed nor opened
		exe 'sign define IDEsign1 text=O  texthl=IDEHL_FileOpen'.s:iconOpen
		exe 'sign define IDEsign2 text=E texthl=IDEHL_FileEdit'.s:iconEdit
		exe 'sign define IDEsign3 text=RO texthl=IDEHL_FileReadOnly'.s:iconReadOnly
		exe 'sign define IDEsign4 text=C  texthl=IDEHL_FileClose'.s:iconClose
		"                IDESign5 while forcing refresh, marks sign to vanishing -> IDESing0
	endif
	">>>
	if s:IDE_hasMapTabMove
		" === Maps for Tab Movements ============================================<<<
		nnoremap <script> <Plug>Move2LeftTab :call <SID>DoMove2LeftTab()<CR>
		if exists("g:IDE_MapMove2LeftTab") && g:IDE_MapMove2LeftTab != ''
			if !hasmapto('<Plug>Move2LeftTab')
				exe 'nmap <silent> ' . g:IDE_MapMove2LeftTab . ' <Plug>Move2LeftTab'
				exe 'map <silent> ' . g:IDE_MapMove2LeftTab . ' <Plug>Move2LeftTab'
				exe 'imap <silent> ' . g:IDE_MapMove2LeftTab . ' <ESC> <Plug>Move2LeftTab <CR>i'
			endif
		endif
		nnoremap <script> <Plug>Move2RightTab :call <SID>DoMove2RightTab()<CR>
		if exists("g:IDE_MapMove2RightTab") && g:IDE_MapMove2RightTab != ''
			if !hasmapto('<Plug>MoveToRightTab')
				exe 'nmap <silent> ' . g:IDE_MapMove2RightTab . ' <Plug>Move2RightTab'
				exe 'map <silent> ' . g:IDE_MapMove2RightTab . ' <Plug>Move2RightTab'
				exe 'imap <silent> ' . g:IDE_MapMove2RightTab . ' <ESC> <Plug>Move2RightTab <CR>i'
			endif
		endif
		">>>
	endif
	delfunction s:SetupVariablesFromFlag
	delfunction s:Set
	" restore 'cpo'
	let &cpoptions = s:cpo_save
	finish
endif
">>>
" === Ensure the remaining of the script is sourced only once ============<<<
if !exists('s:IDE_sid')
	" Two or more versions of IDE plugin are installed. Don't
	" load this version of the plugin.
	finish
endif
unlet! s:IDE_sid
if g:IDE_isLoaded != 'base_load_done'
	" restore 'cpo'
	let &cpoptions = s:cpo_save
	finish
endif
let g:IDE_isLoaded = 'available'
" IDE plugin functionality is available
">>>
" === IDE_VariableInitialization() =======================================<<<
" Set the resize commands to nothing
function! s:IDE_VariableInitialization()
	" === can be given an initial configuration
	let s:IDE_isLogging = 0
	let s:IDE_LogFile = ''
	let s:IDE_isTracing = 1
	" === To be handled by the IDE script only, do NOT modify
	let s:IDE_LogMessage = ''
	let s:IDE_FileHasBeenClosed = 0
	let s:IDE_syntaxCounter = 0
	let s:IDE_syntaxUpdate = 0
	let s:IDE_syntaxThreshold = 0
	let s:IDE_autocmdID = 0
	let s:IDE_isSyntaxWorking = s:IDE_isSyntaxCapable
	let s:IDE_isInInsert = 0
	let s:IDE_LastBuffer = -1
	let s:IDE_isWindowSizeChanged = -1
	let s:IDE_userWindowWidth = g:IDE_WindowWidth
	let s:IDE_isBriefHelp = 1
	let s:IDE_AppName = "none"
	let s:IDE_ProjectName = ''
	let s:IDE_Buffer = -1
	let s:IDE_isModified = 0
	let s:IDE_ProjectEND = 0
	let s:IDE_ProjectID = 0
	let s:IDE_isToggled = 0
	" === Do not waste memory, make sure everything is trash before reusing
	unlet! s:IDE_ProjectSyn s:IDE_Launched s:IDE_File s:IDE_Project s:IDE_BufferMap s:IDE_PendingUpdate
	let s:IDE_ProjectSyn = {}
	let s:IDE_Launched = {}
	let s:IDE_File = {}
	let s:IDE_Project = {}
	"IDEA: change buffer map so it only has loaded buffer files
	let s:IDE_BufferMap = {}
	let s:IDE_PendingUpdate = {}
	let s:IDE_MaxDepth = 0
endfunction
">>>
" === IDE_ShowEnvironment() ==============================================<<<
function s:IDE_ShowEnvironment()
	echohl WarningMsg
	echo "IDE enviroment variables"
	echo " "
	echo "IDE Advance Flag: '".g:IDE_AdvancedFlags."'"
	echohl MoreMsg
	echo "  [+] s:IDE_isEnableFoldColumn       = ".s:IDE_isEnableFoldColumn
	echo "  [f] s:IDE_isGainFocusOnToggle      = ".s:IDE_isGainFocusOnToggle
	echo "  [M] s:IDE_hasMapMake               = ".s:IDE_hasMapMake
	echo "  [o] s:IDE_isEnableSignMarks        = ".s:IDE_isEnableSignMarks
	echo "  [O] s:IDE_isEnableSignMarksClose   = ".s:IDE_isEnableSignMarksClose
	echo "  [R] s:IDE_isAtRightWindow          = ".s:IDE_isAtRightWindow
	echo "  [S] s:IDE_isSyntaxCapable          = ".s:IDE_isSyntaxCapable
	echo "  [T] s:IDE_hasMapTabMove            = ".s:IDE_hasMapTabMove
	echo "  [u] s:IDE_updateWinManagerAlways   = ".s:IDE_updateWinManagerAlways
	echo "  [z] s:IDE_foldProjectEntries       = ".s:IDE_foldProjectEntries
	echo " "
	echohl WarningMsg
	echo "IDE Project Flag: '".g:IDE_ProjectFlags."'"
	echohl MoreMsg
	echo "  [b] s:IDE_isUsingBrowse            = ".s:IDE_isUsingBrowse
	echo "  [c] s:IDE_isCloseOnOpen            = ".s:IDE_isCloseOnOpen
	echo "  [F] s:IDE_isFloating               = (DEPRECATED)"
	echo "  [g] s:IDE_hasMapToggle             = ".s:IDE_hasMapToggle
	echo "  [i] s:IDE_isShowingInfo            = ".s:IDE_isShowingInfo
	echo "  [l] s:IDE_usesCommandLCD           = (DEPRECATED)"
	echo "  [L] s:IDE_isChangingCWD            = ".s:IDE_isChangingCWD
	echo "  [m] s:IDE_shadowProjectBuffer      = (DEPRECATED)"
	echo "  [n] s:IDE_isSshowLineNumber        = ".s:IDE_isShowLineNumber
	echo "  [s] s:IDE_doSyntaxOnWindowIDE      = ".s:IDE_doSyntaxOnWindowIDE
	echo "  [S] s:IDE_isSortingOn              = ".s:IDE_isSortingOn
	echo "  [t] s:IDE_isToggleSize             = ".s:IDE_isToggleSize
	echo "  [T] s:IDE_isSubProjectToTop        = ".s:IDE_isSubProjectToTop
	echo "  [v] s:IDE_isVimGrep                = ".s:IDE_isVimGrep
	echo " "
	echohl WarningMsg
	echo "IDE State variables: (valid while the project is loaded)"
	echohl MoreMsg
	echo "  s:IDE_cmdLocate                = ".s:IDE_cmdLocate
	"echo "  s:IDE_cmdResize                = ".s:IDE_cmdResize
	echo "  s:IDE_LastBuffer               = ".s:IDE_LastBuffer
	echo "  s:IDE_isWindowSizeChanged      = ".s:IDE_isWindowSizeChanged
	echo "  s:IDE_userWindowWidth          = ".s:IDE_userWindowWidth
	echo "  s:IDE_AppName                  = ".s:IDE_AppName
	echo "  s:IDE_ProjectName              = ".s:IDE_ProjectName
	echo "  s:IDE_Launched['name']         = ".s:IDE_Launched['name']
	echo "  s:IDE_Launched['file']         = ".s:IDE_Launched['file']
	echo "  s:IDE_Buffer                   = ".s:IDE_Buffer
	echo "  s:IDE_isModified               = ".s:IDE_isModified
	echo "  s:IDE_isLogging                = ".s:IDE_isLogging
	echo "  s:IDE_LogFile                  = ".s:IDE_LogFile
	echo "  s:IDE_isBriefHelp              = ".s:IDE_isBriefHelp
	echo "  s:brief_help_size              = ".s:brief_help_size
	echo "  s:full_help_size               = ".s:full_help_size
	echo "  s:IDE_cmdCd                    = ".s:IDE_cmdCd
	echo "  s:IDE_PluginFoder              = ".s:IDE_PluginFolder
	if s:IDE_isSyntaxCapable != 0
		echo " "
		echohl WarningMsg
		echo "IDE Syntax variables: (valid while project is loaded)"
		echohl MoreMsg
		if exists('s:IDE_ProjectSyn')
			echo "  * syntax for IDE project       = ".s:IDE_ProjectSyn['root']
			echo "  * generated syntax file        = ".s:IDE_ProjectSyn['syntax']
			echo "  * files given to ctags         = ".s:IDE_ProjectSyn['files']
			echo "  * generated tags file          = ".s:IDE_ProjectSyn['tags']
		else
			echo "  ** IDE Project syntax is not properly setup ** "
		endif
		echo "  s:IDE_syntaxScript             = ".s:IDE_syntaxScript
		echo "  s:IDE_syntaxCounter            = ".s:IDE_syntaxCounter
		echo "  s:IDE_syntaxUpdate             = ".s:IDE_syntaxUpdate
		echo "  s:IDE_syntaxThreshold          = ".s:IDE_syntaxThreshold
		echo "  s:IDE_isSyntaxWorking          = ".s:IDE_isSyntaxWorking
	endif
	echo " "
	echohl WarningMsg
	echo "Global variables:"
	echohl MoreMsg
	echo "  g:IDE_Title                    = ".g:IDE_Title
	echo "  g:IDE_isLoaded                 = ".g:IDE_isLoaded
	echo "  g:IDE_WindowWidth              = ".g:IDE_WindowWidth
	echo "  g:IDE_WindowIncrement          = ".g:IDE_WindowIncrement
	echo "  g:IDE_MapMove2RightTab         = ".g:IDE_MapMove2RightTab
	echo "  g:IDE_MapMove2LeftTab          = ".g:IDE_MapMove2LeftTab
	echo "  g:IDE_MapProjectToggle         = ".g:IDE_MapProjectToggle
	if s:IDE_hasMapMake
		echo "  g:IDE_MainTarget_1             = ".g:IDE_MainTarget_1
		echo "  g:IDE_MainTarget_2             = ".g:IDE_MainTarget_2
		echo "  g:IDE_MainTarget_3             = ".g:IDE_MainTarget_3
		echo "  g:IDE_MapMakeMainTarget_1      = ".g:IDE_MapMakeMainTarget_1
		echo "  g:IDE_MapMakeMainTarget_2      = ".g:IDE_MapMakeMainTarget_2
		echo "  g:IDE_MapMakeMainTarget_3      = ".g:IDE_MapMakeMainTarget_3
		echo "  g:IDE_ThisTarget_1             = ".g:IDE_ThisTarget_1
		echo "  g:IDE_ThisTarget_2             = ".g:IDE_ThisTarget_2
		echo "  g:IDE_ThisTarget_3             = ".g:IDE_ThisTarget_3
		echo "  g:IDE_MapMakeThisTarget_1      = ".g:IDE_MapMakeThisTarget_1
		echo "  g:IDE_MapMakeThisTarget_2      = ".g:IDE_MapMakeThisTarget_2
		echo "  g:IDE_MapMakeThisTarget_3      = ".g:IDE_MapMakeThisTarget_3
	endif
	echo " "
	let l:separator = "  "
	echohl WarningMsg
	echo "Internal IDE content details: [Projects]"
	echohl MoreMsg
	echo "id".l:separator."project_name".l:separator."home".l:separator."cd".l:separator."filter".l:separator."flags".l:separator."script_in".l:separator."script_out".l:separator."parent_id eof"
	echohl None
	for id in keys(s:IDE_Project)
		echo id.l:separator.s:IDE_Project[id]["name"].
					\l:separator.s:IDE_Project[id]["home"].
					\l:separator.s:IDE_Project[id]["cd"].
					\l:separator.s:IDE_Project[id]["filter"].
					\l:separator.s:IDE_Project[id]["flags"].
					\l:separator.s:IDE_Project[id]["in"].
					\l:separator.s:IDE_Project[id]["out"].
					\l:separator.s:IDE_Project[id]["parent"].
					\l:separator.s:IDE_Project[id]["end"]
	endfor
	echo " "
	echohl WarningMsg
	echo "Internal IDE content details: [Files]"
	echohl MoreMsg
	echo "id".l:separator."file_name".l:separator."file_status[0:NotOpen 1:Open 2:Edited 3:ReadOnly 4:Closed]".l:separator."parent_project_id"
	echohl None
	for id in keys(s:IDE_File)
		echo id.l:separator.s:IDE_File[id]["name"].
					\l:separator.s:IDE_File[id]["status"].
					\l:separator.s:IDE_File[id]["parent"]
	endfor
	echo " "
	echohl WarningMsg
	echo "Internal file map content details:"
	echohl MoreMsg
	echo "absolute_buffer_file_name".l:separator."id"
	echohl None
	for id in keys(s:IDE_BufferMap)
		echo id.l:separator.s:IDE_BufferMap[id]
		"echo id.l:separator.s:IDE_BufferMap[id]["name"].
	endfor
	echo " "
	echohl WarningMsg
	echo "Internal files which are pending syntax update"
	echohl MoreMsg
	echo "id".l:separator."pending_status_sign".l:separator."file_name"
	echohl None
	for id in keys(s:IDE_PendingUpdate)
		echo id.l:separator.s:IDE_PendingUpdate[id]['status'].
					\l:separator.s:IDE_PendingUpdate[id]['name']
	endfor
endfunction
">>>
"================ Makefile ===========================================================
" === Makefile <Plug> maps ===============================================<<<
nnoremap <script> <Plug>MakeMainTarget_1 :call <SID>IDE_MakeMainProject(g:IDE_MainTarget_1)<CR>
nnoremap <script> <Plug>MakeMainTarget_2 :call <SID>IDE_MakeMainProject(g:IDE_MainTarget_2)<CR>
nnoremap <script> <Plug>MakeMainTarget_3 :call <SID>IDE_MakeMainProject(g:IDE_MainTarget_3)<CR>
nnoremap <script> <Plug>MakeThisTarget_1 :call <SID>IDE_MakeThisProject(g:IDE_ThisTarget_1)<CR>
nnoremap <script> <Plug>MakeThisTarget_2 :call <SID>IDE_MakeThisProject(g:IDE_ThisTarget_2)<CR>
nnoremap <script> <Plug>MakeThisTarget_3 :call <SID>IDE_MakeThisProject(g:IDE_ThisTarget_3)<CR>
">>>
"=== IDE_MakeThisProject() ==============================================<<<
function! s:IDE_MakeThisProject(...)
	if a:0 == 0 || !exists('g:IDE_Title')
		call s:IDE_WarnMsg("Nothing to do.")
		return
	endif
	let l:compileType = a:1
	if l:compileType == ''
		let l:compileMsg = 'Making default target in project '
	else
		let l:compileMsg = 'Making '.l:compileType.' in project '
	endif
	if bufnr('%') == s:IDE_Buffer
		let l:savedir = getcwd()
		let l:current_id = s:IDE_GetID(line('.'))
		let l:parent_id = s:IDE_GetThisProjectBegin(l:current_id)
		let l:parent_home = s:IDE_Project[l:parent_id]['home']
		let l:parent_name = s:IDE_Project[l:parent_id]['name']
		silent exe "cd " . l:parent_home
		let l:makefile = s:IDE_FindMakefile('.')
		if l:makefile == ''
			call s:IDE_WarnMsg("Nothing to do. Cannot retrieve a makefile for project ".l:parent_name)
		else
			call s:IDE_InfoMsg(l:compileMsg . l:parent_name)
			exe 'make -f' . l:makefile . " " . l:compileType
		endif
		if l:parent_home != l:savedir
			silent exe "cd " . l:savedir
		endif
	else
		let l:bufname = s:IDE_GetConsistentFileName('%:p')
		if has_key(s:IDE_BufferMap,l:bufname)
			let l:makefile = s:IDE_FindMakefile('.')
			if l:makefile == ''
				call s:IDE_WarnMsg("Nothing to do. Cannot retrieve a makefile in current folder.")
			else
				call s:IDE_InfoMsg(l:compileMsg . l:parent_name)
				exe 'make -f' . l:makefile . " " . l:compileType
			endif
		else
			call s:IDE_ErrorMsg("File ".fnamemodify(l:bufname,':t')." is not part of any project")
		endif
	endif
endfunction
">>>
"=== IDE_MakeMainProject() ==============================================<<<
function! s:IDE_MakeMainProject(...)
	if a:0 == 0 || !exists('g:IDE_Title') || !exists('s:IDE_Project')
		call s:IDE_WarnMsg("Nothing to do.")
		return
	endif
	let l:compileType = a:1
	if l:compileType == ''
		let l:compileMsg = 'Making default target'
	else
		let l:compileMsg = 'Making ' . l:compileType . ' target'
	endif
	let l:makedir = s:IDE_Project[s:IDE_ProjectID]['home']
	call s:IDE_InfoMsg("Using makefile in ".l:makedir)
	let l:makefile = s:IDE_FindMakefile(l:makedir)
	if l:makefile == ''
		call s:IDE_WarnMsg("Nothing to do. Cannot retrieve a makefile in project folder ".l:makedir)
	else
		let l:savedir = getcwd()
		call s:IDE_InfoMsg(l:compileMsg.' in project '.s:IDE_Project[s:IDE_ProjectID]['name'].' ('.s:IDE_Launched['name'].')')
		silent exe "cd " . l:makedir
		exe 'make -f '.l:makefile.' '.l:compileType
		if l:makedir != l:savedir
			silent exe "cd " . l:savedir
		endif
	endif
endfunction
">>>
" === IDE_FindMakefile() =================================================<<<
function! s:IDE_FindMakefile(inpath)
	let l:makedir=a:inpath
	let l:makefile = ''
	for item in g:IDE_MakefileList
		if filereadable(l:makedir.'/'.item)
			let l:makefile = l:makedir.'/'.item
			break
		endif
	endfor
	return l:makefile
endfunction
">>>
" === IDE_SearchFor() ====================================================<<<
function! s:IDE_SearchFor(word,scope)
	let l:bufname = s:IDE_GetConsistentFileName('%:p')
	call s:IDE_TraceLog("IDE_SearchFor(".a:word.",".a:scope.")  ".l:bufname)
	if has_key(s:IDE_BufferMap,l:bufname)
		if a:scope
			let l:proj_id = s:IDE_ProjectID
		else
			let l:id = s:IDE_BufferMap[l:bufname]
			let l:proj_id = s:IDE_File[l:id]['parent']
		endif
		call s:GrepAll(l:proj_id, a:word, 1)
	else
		call s:IDE_WarnMsg("File does not belong to IDE, nothing to search")
	endif
endfunction
function! s:IDE_SearchForWord(scope)
	call s:IDE_SearchFor(expand("<cword>"),a:scope)
endfunction
">>>
"================ Help ===============================================================
" === IDE_DisplayHelp() ==================================================<<<
" === Display a help menu within the IDE windows
" === guarantee to be in focus
function! s:IDE_DisplayHelp()
	if s:IDE_AppName == "winmanager"
		" To handle a bug in the winmanager plugin, add a space at the last line
		call setline('$', ' ')
	endif
	if s:IDE_isBriefHelp
		" Add the brief help
		call append(0, '" Press <F1> to display help text')
		call append(1, s:IDE_Divider)
	else
		let l:nomark = " "
		let l:ismark = "~"
		let s:full_help_size = 0
		function! s:AppendHelp(key,msg)
			if a:key == ''
				return
			endif
			let l:key = a:key
			if len(l:key)<15
				let l:padding = strpart("                      ", 0, 15-len(l:key))
				let l:key .= l:padding
			endif
			if a:key != ''
				call append(s:full_help_size, '" '.l:key.a:msg)
				let s:full_help_size +=1
			endif
		endfunction
		" Add the extensive help
		call append(s:full_help_size,'[Local mappings]')
		let s:full_help_size+=1
		call s:AppendHelp('<enter>',': Open/Close project fold. Open file. Jump to file')
		call s:AppendHelp('<space>',': Increase/Decrease IDE window')
		call s:AppendHelp('<C-up>',': Move up the file/project under the cursor')
		call s:AppendHelp('<C-down>',': Move down the file/project under the cursor')
		call s:AppendHelp('+/-',': Open/Close a fold')
		call s:AppendHelp('*/=',': Open/Close all folds')
		call s:AppendHelp('dd',': Deletes a file or project')
		call s:AppendHelp('q',': Close the IDE window')
		call s:AppendHelp('<F1>',': Remove help text')
		call s:AppendHelp('<F2>',': Save project "'.s:IDE_Launched['name'].'"')
		call s:AppendHelp('<S-F2>',': Save project "'.s:IDE_Launched['name'].'" and Exit')
		if s:IDE_isModified
			call s:AppendHelp('<C-F2>',': Exit project. Changes made to "'.s:IDE_Launched['name'].'" will be lost')
		else
			call s:AppendHelp('<C-F2>',': Exit project')
		endif
		call s:AppendHelp(g:IDE_Info,': Show information for the current file/project')
		call s:AppendHelp(g:IDE_InfoDetailed,': Show detailed information')
		call s:AppendHelp(g:IDE_LoadAll,': Load all files in the current project')
		call s:AppendHelp(g:IDE_LoadAllRecursive,': As above but include all sub projects ')
		call s:AppendHelp(g:IDE_WipeAll,': Wipe all files in the current project')
		call s:AppendHelp(g:IDE_WipeAllRecursive,': As above but include all sub projects')
		call s:AppendHelp(g:IDE_GrepAll,': Greps all files in the current project')
		call s:AppendHelp(g:IDE_GrepAllRecursive,': As above but include all sub projects')
		call s:AppendHelp(g:IDE_Create,': Create a project')
		call s:AppendHelp(g:IDE_CreateRecursive,': Create a project and its sub projects')
		call s:AppendHelp(g:IDE_RefreshContent,': Refresh the content of a project from its directory')
		call s:AppendHelp(g:IDE_RefreshContentRecursive,': As above but include all sub projects')
		call s:AppendHelp(g:IDE_SortContent,': Sort the content of a project')
		call s:AppendHelp(g:IDE_SortContentRecursive,': As above but include all sub projects')
		call append(s:full_help_size,'[File mappings]')
		let s:full_help_size+=1
		call s:AppendHelp(g:IDE_FetchInProjectRecursive,': Fetch the word under the cursor in the current project')
		call s:AppendHelp(g:IDE_FetchInAllProjects,': Fetch the word under the cursor in all projects')
		call append(s:full_help_size,'[Global mappings]')
		let s:full_help_size+=1
		if s:IDE_hasMapMake
			let l:main = s:IDE_Project[s:IDE_ProjectID]['name']
			call s:AppendHelp(g:IDE_MapMakeMainTarget_1,': Make '.l:main.' project '.g:IDE_MainTarget_1)
			call s:AppendHelp(g:IDE_MapMakeMainTarget_2,': Make '.l:main.' project '.g:IDE_MainTarget_2)
			call s:AppendHelp(g:IDE_MapMakeMainTarget_3,': Make '.l:main.' project '.g:IDE_MainTarget_3)
			call s:AppendHelp(g:IDE_MapMakeThisTarget_1,': Make current project '.g:IDE_ThisTarget_1)
			call s:AppendHelp(g:IDE_MapMakeThisTarget_2,': Make current project '.g:IDE_ThisTarget_2)
			call s:AppendHelp(g:IDE_MapMakeThisTarget_3,': Make current project '.g:IDE_ThisTarget_3)
		endif
		if s:IDE_hasMapToggle
			call s:AppendHelp(g:IDE_MapProjectToggle,': Toggle IDE window')
		endif
		call append(s:full_help_size,s:IDE_Divider)
		let s:full_help_size+=1
	endif
endfunction
">>>
" === IDE_ToggleHelp() ===================================================<<<
" === Toggle IDE plugin help text between the full version and the brief version
" === guarantee to be in focus
function! s:IDE_ToggleHelp()
	" Include the empty line displayed after the help text
	let l:old_line = line('.')
	let l:new_line = 0
	setlocal modifiable
	" Set report option to a huge value to prevent informational messages
	" while deleting the lines
	let l:old_report = &report
	set report=99999
	" Remove the currently highlighted tag. Otherwise, the help text
	" might be highlighted by mistake
	match none
	" Toggle between brief and full help text
	if s:IDE_isBriefHelp
		let s:IDE_isBriefHelp = 0
		" Remove the previous help
		exe 'silent! 1,' . s:brief_help_size . ' delete _'
		if (l:old_line <= s:brief_help_size)
			let l:old_line = s:brief_help_size+1
		endif
		let l:new_line = l:old_line + (s:full_help_size-s:brief_help_size)
		if l:new_line >= winheight(0)
			let l:new_line = s:full_help_size+1
		endif
	else
		let s:IDE_isBriefHelp = 1
		" Remove the previous help
		exe 'silent! 1,' .s:full_help_size . ' delete _'
		if (l:old_line <= s:full_help_size)
			let l:old_line = s:full_help_size+1
		endif
		let l:new_line = l:old_line - (s:full_help_size-s:brief_help_size)
		if l:new_line >= winheight(0)
			let l:new_line = s:brief_help_size+1
		endif
	endif
	call s:IDE_DisplayHelp()
	normal! gg
	exe l:new_line
	" Enlarge Full help window if needed so it can be read at once
	let l:windowWidth = winwidth('.')
	if !s:IDE_isBriefHelp
		if l:windowWidth <= s:IDE_userWindowWidth
			let l:windowWidth += g:IDE_WindowIncrement
			exe 'silent! vertical resize '.l:windowWidth
		endif
	else
		if l:windowWidth > s:IDE_userWindowWidth
			exe 'silent! vertical resize '.s:IDE_userWindowWidth
		endif
	endif
	" Restore the report option
	let &report = l:old_report
	if !s:IDE_isModified
		call setbufvar(g:IDE_Title, '&modified', '0')
	endif
	setlocal nomodifiable
endfunction
">>>
"================ Tab Label ==========================================================
" === IDE_OtherTabLabel() ================================================<<<
function! s:IDE_OtherTabLabel()
	let l:label = ''
	let bufnrlist = tabpagebuflist(v:lnum)
	for bufnr in bufnrlist
		if getbufvar(bufnr, "&modified")
			let l:label = '+'
			break
		endif
	endfor
	let l:wincount = tabpagewinnr(v:lnum, '$')
	if l:wincount > 1
		let l:label .= l:wincount
	endif
	if l:label != ''
		let l:label .= ' '
	endif
	let l:name = bufname(bufnrlist[tabpagewinnr(v:lnum) - 1])
	if l:name == ''
		" give a name to no-name documents
		if &buftype=='quickfix'
			let l:name = '[Quickfix List]'
		else
			let l:name = '[No Name]'
		endif
	else
		" get only the file name
		let l:name = fnamemodify(l:name,":t")
	endif
	let l:label .= l:name
	return l:label
endfunction
">>>
" === IDE_ProjectTabLabel() ==============================================<<<
function! IDE_ProjectTabLabel()
	let l:label = ''
	let l:bufname=escape(substitute(expand('%:p', 0), '\\', '/', 'g'), ' ')
	let l:bufname=substitute(l:bufname,'\.\/','','g')
	let l:bufnbr = bufnr('%')
	if l:bufnbr == s:IDE_Buffer
		let l:label = s:IDE_useDigraphs ?  "ⅰ∂ε [" : 'IDE ['
		if s:IDE_isModified
			let l:label .= '+'
		endif
		let l:label .= s:IDE_ProjectName
		let l:label .= "]"
	elseif has_key(s:IDE_BufferMap,l:bufname)
		" Append the number of windows in the tab page if more than one
		let l:wincount = tabpagewinnr(v:lnum, '$')
		if l:wincount > 1
			let l:label = l:wincount.' '
		else
			let l:label = ''
		endif
		let l:id = s:IDE_BufferMap[l:bufname]
		let l:label .= s:IDE_File[l:id]["name"]
		if getbufvar(l:bufnbr, "&modified")
			let l:label .= '+'
		endif
		let l:label .= s:IDE_useDigraphs ? "⌂" : "'"
	else
		let l:label = s:IDE_OtherTabLabel()
	endif
	" Append the buffer name
	return l:label
endfunction
">>>
" === IDE_ProjectTabToolTip() ============================================<<<
function! IDE_ProjectTabToolTip()
	let l:tip = ''
	let bufnrlist = tabpagebuflist(v:lnum)
	for bufnr in bufnrlist
		" separate buffer entries
		if l:tip!=''
			let l:tip .= "\n"
		endif
		" Add name of buffer
		let l:name=bufname(bufnr)
		if l:name == ''
			" give a name to no name documents
			if getbufvar(bufnr,'&buftype')=='quickfix'
				let l:name = '[Quickfix List]'
			else
				let l:name = '[No Name]'
			endif
		elseif bufnr == s:IDE_Buffer
			let l:name = s:IDE_useDigraphs ? "ⅰ∂ε" : "IDE Buffer"
		endif
		let l:tip.=l:name
		" add modified/modifiable flags
		if getbufvar(bufnr, "&modified")
			let l:tip .=  ' [+]'
		endif
		if getbufvar(bufnr, "&modifiable")==0
			let l:tip .= ' [RO]'
		endif
	endfor
	return l:tip
endfunction
">>>
"================ Messges ============================================================
" === IDE_LogEnable() ====================================================<<<
" === Enable logging of taglist debug messages.
function! s:IDE_LogEnable(...)
	let s:IDE_isLogging = 1
	" Check whether a valid file name is supplied.
	if a:1 != ''
		let s:IDE_LogFile = fnamemodify(a:1, ':p')
		" Empty the log file
		exe 'redir! > ' . s:IDE_LogFile
		redir END
		" Check whether the log file is present/created
		if !filewritable(s:IDE_LogFile)
			call s:IDE_WarnMsg('Unable to create log file '. s:IDE_LogFile)
			let s:IDE_LogFile = ''
		endif
	endif
endfunction
">>>
" === IDE_LogDisable() ===================================================<<<
" === Disable logging of taglist debug messages.
function! s:IDE_LogDisable(...)
	let s:IDE_isLogging = 0
	let s:IDE_LogFile = ''
endfunction
">>>
" === IDE_ShowLog() ======================================================<<<
" === Display the taglist debug messages in a new window
function! s:IDE_ShowLog()
	if s:IDE_LogMessage == ''
		call s:IDE_WarnMsg('No log messages.')
		return
	endif
	" Open a new window to display the taglist debug messages
	new ide_log.dump
	map <buffer> <silent> <ESC> :bwipeout!<CR>
	" Delete all the lines (if the buffer already exists)
	silent! %delete _
	" Add the messages
	silent! put =s:IDE_LogMessage
	" Move the cursor to the first line
	normal! G
	call setbufvar(bufnr("ide_log.dump"), '&modified', '0')
endfunction
">>>
" === IDE_LogMsg() =======================================================<<<
" === Log the supplied debug message along with the time =================
function! s:IDE_LogMsg(msg)
	if s:IDE_isLogging
		if s:IDE_LogFile != '' && filewritable(s:IDE_LogFile)
			exe 'redir >> ' . s:IDE_LogFile
			silent echon strftime('%H:%M:%S') . ': ' . a:msg . "\n"
			redir END
		else
			" Log the message into a variable
			" Retain only the last 3000 characters
			let len = strlen(s:IDE_LogMessage)
			if len > 10000
				let s:IDE_LogMessage = strpart(s:IDE_LogMessage, len - 10000)
			endif
			let s:IDE_LogMessage = s:IDE_LogMessage . strftime('%H:%M:%S') . ': ' . a:msg . "\n"
		endif
	endif
endfunction
">>>
" === IDE_TraceLog() =====================================================<<<
" === Log the supplied debug message along with the time =================
function! s:IDE_TraceLog(msg)
	if s:IDE_DumpDebugToFile
		call s:IDE_DebugMsg("IDE Trace: ".a:msg)
	elseif s:IDE_isDebugging
		call s:IDE_WarnMsg("[Trace] ".a:msg)
	elseif s:IDE_isTracing
		call s:IDE_LogMsg("Trace: ".a:msg)
	endif
endfunction
">>>
" === IDE_WarnMsg() ======================================================<<<
" === Display a warning message using highlight group ====================
function! s:IDE_WarnMsg(msg)
	if s:IDE_DumpDebugToFile
		call s:IDE_DebugMsg("IDE Warning: ".a:msg)
	else
		echohl WarningMsg
		"silent! redraw
		echomsg "IDE Warning: ".a:msg
		echohl None
	endif
endfunction
">>>
" === IDE_ErrorMsg() =====================================================<<<
" === Display an error message ====================
function! s:IDE_ErrorMsg(msg)
	echohl ErrorMsg
	"silent! redraw
	echomsg "IDE Error: ".a:msg
	echohl None
	if s:IDE_DumpDebugToFile
		call s:IDE_DebugMsg("IDE Error: ".a:msg)
	endif
endfunction
">>>
" === IDE_WarnMsg() ======================================================<<<
" === Display a warning message using highlight group ====================
function! s:IDE_DebugMsg(msg)
	if !s:IDE_DumpDebugToFile
		call s:IDE_ErrorMsg("IDE Error: while redirecting to debug log \"".a:msg."\"")
	else
		exe 'redir >> ' . s:IDE_DebugFile
		silent echo a:msg
		redir END
	endif
endfunction
">>>
" === IDE_InfoMsg() ======================================================<<<
" === Display a info message using highlight group ====================
function! s:IDE_InfoMsg(msg)
	echohl MoreMsg
	silent! redraw
	echomsg "IDE Info: ".a:msg
	echohl None
endfunction
">>>
" === IDE_Assert() =======================================================<<<
function! s:IDE_Assert(condition,msg)
	if !a:condition
		call s:IDE_ErrorMsg('[Assertion Failed] '.a:msg)
	endif
endfunction
">>>
" === IDE debug support
" === IDE_StartDebug() ===================================================<<<
function! s:IDE_StartDebug()
	if s:IDE_isDebugging
		call s:IDE_InfoMsg("Starting with debug facilities")
		" do not let this file grow over time
		if filewritable(s:IDE_DebugFile)
			call s:IDE_InfoMsg("Warnings and Traces will be redirected to file ".s:IDE_DebugFile)
			let s:IDE_DumpDebugToFile = 1
			exe 'redir! >'.s:IDE_DebugFile
			redir END
		else
			call s:IDE_InfoMsg("Warnings and Traces will be redirected to screen")
		endif
	endif
endfunction
">>>
" === IDE_StopDebug() ====================================================<<<
function! s:IDE_StopDebug()
	if s:IDE_DumpDebugToFile
		echo "------------------------------------------"
		call s:IDE_ShowEnvironment()
		echo "------------------------------------------"
		redir END
	endif
	let s:IDE_DumpDebugToFile = 0
endfunction
">>>
"
"================ Buffer Management ==================================================
"
" === Buffer auto comands
" === IDE_RemoveFileAutoCommands() =======================================<<<
function! s:IDE_RemoveFileAutoCommands()
	while s:IDE_autocmdID > 0
		let l:autocmd_to_remove = "IDE_FileAutoCommands_".s:IDE_autocmdID
		let s:IDE_autocmdID -= 1
		exe 'silent! autocmd! '.l:autocmd_to_remove
	endwhile
endfunction
">>>
" === IDE_ExeWithoutAucmds() =============================================<<<
" === Execute the specified Ex command after disabling autocommands ======
function! s:IDE_ExeWithoutAucmds(cmd)
	call s:IDE_TraceLog('IDE_ExeWithoutAucmds('.a:cmd.')')
	let l:old_eventignore = &eventignore
	set eventignore=all
	exe a:cmd
	let &eventignore = l:old_eventignore
endfunction
">>>
" === IDE_RefreshWindow() ================================================<<<
function! s:IDE_RefreshWindow()
	call s:IDE_TraceLog('IDE_RefreshWindow()')
	" Set report option to a huge value to prevent informational messages
	" while deleting the lines
	let old_report = &report
	set report=99999
	" Mark the buffer as modifiable
	setlocal modifiable
	call s:IDE_DisplayHelp()
	" Mark the buffer as not modifiable
	setlocal nomodifiable
	let &report = old_report
endfunction
">>>
" === IDE_HandleSwapFile_au() ============================================<<<
function! s:IDE_HandleSwapFile_au()
	call s:IDE_TraceLog("IDE_HandleSwapFile_au()")
	"let l:filename = escape(substitute(expand("<afile>:p"), '\\', '/', 'g'), ' ')
	let l:filename = expand("<afile>")
	let l:choice = confirm('IDE found a swapfile while attempting to open the file '.l:filename.".\n".
				\'What do you recommend doing?', "&Open read-only\n&Edit file\n&Recover from swap\n&Delete swap\n&Nothing",2)
	if l:choice == 1
		let v:swapchoice = 'o'
		call s:IDE_InfoMsg('Opening file as read-only, swapfile '.v:swapname.' will be kept.')
	elseif l:choice == 2
		let v:swapchoice = 'e'
		call s:IDE_InfoMsg('Editing file anyway.')
	elseif l:choice == 3
		let v:swapchoice = 'r'
		call s:IDE_InfoMsg('Recovering file from swapfile.')
	elseif l:choice == 4
		let v:swapchoice = 'd'
		call s:IDE_InfoMsg('Deleting swapfile '.v:swapname)
	else
		let v:swapchoice = 'q'
		call s:IDE_InfoMsg('Stopping command by user decision.')
	endif
endfunction
">>>
" === IDE_FileHasBeenClosed_au() =========================================<<<
function! s:IDE_FileHasBeenClosed_au()
	let s:IDE_FileHasBeenClosed = 1
endfunction
">>>
" === IDE_RecordWindowsize_au() ==========================================<<<
function! s:IDE_RecordWindowSize_au()
	if s:IDE_isToggled == 0
		let s:IDE_userWindowWidth=winwidth('.')
	endif
	call s:IDE_TraceLog('IDE_RecordWindowSize_au()  #window='.s:IDE_userWindowWidth)
endfunction
">>>
" === Buffer finish
" === IDE_ExitCmd() ======================================================<<<
function s:IDE_ExitCmd(action)
	if a:action =~ '^cmd!$'
		call s:IDE_Exit()
	else
		if s:IDE_isModified
			call s:IDE_WarnMsg("Add \"!\" to discard all changes made to the ".s:IDE_ProjectName." ide-project.")
		else
			call s:IDE_Exit()
		endif
	endif
endfunction
">>>
" === IDE_WipeoutExit_au() ===============================================<<<
function s:IDE_WipeoutExit_au()
	call s:IDE_WarnMsg("The IDE is being wiped out externally (user command or script), shutting down the IDE")
	call s:IDE_StopDebug()
	call s:IDE_ReleaseAll()
	let g:IDE_isLoaded = "base_load_done"
	unlet g:IDE_Title
endfunction
">>>
" === IDE_Exit() =========================================================<<<
" === could be in or out of focus
function! s:IDE_Exit()
	call s:IDE_TraceLog("IDE_Exit()")
	call s:IDE_StopDebug()
	call s:IDE_ReleaseAll()
	let l:idebuf = bufnr(g:IDE_Title)
	exe "bwipeout! ".l:idebuf
	" Unlet global IDE variables
	let g:IDE_isLoaded="base_load_done"
	unlet g:IDE_Title
endfunction
">>>
" === IDE_SafeExit() =====================================================<<<
" === guarantee to be in focus
function! s:IDE_SafeExit()
	call s:IDE_TraceLog("IDE_SafeExit()")
	call s:IDE_GainFocusIfOpenInWindows()
	if s:IDE_isModified
		let l:choice = confirm('The ide-project '.s:IDE_Launched['name'].' has been modified'."\n".
					\'Do you want to save it?', "&YES\n&NO", 1)
		if l:choice==1
			call s::IDE_SaveProject()
		endif
	endif
	call s:IDE_Exit()
endfunction
">>>
" === IDE_SaveProject() ==================================================<<<
" === guarantee to be in focus
function! s:IDE_SaveProject()
	call s:IDE_TraceLog("IDE_SaveProject()")
	let l:curline=line('.')
	setlocal modifiable
	" Remove help
	if s:IDE_isBriefHelp
		exe 'silent! 1,' . s:brief_help_size . ' delete _'
	else
		exe 'silent! 1,' .s:full_help_size . ' delete _'
		let l:curline-=s:full_help_size
		let l:curline+=3
		if (l:curline<1)
			let l"curline=3
		endif
	endif
	silent! exe "write! ".s:IDE_Launched['file_esc']
	let s:IDE_isBriefHelp = 1
	call append(0, '" Press <F1> to display help text')
	call append(1,s:IDE_Divider)
	"let l:newline = 3
	exe l:curline
	let s:IDE_isModified = 0
	setlocal nomodifiable
	call s:IDE_InfoMsg('project-file "'.s:IDE_Launched['name'].'" was saved.')
endfunction
">>>
" === IDE_SaveProjectAndExit() ===========================================<<<
" === could be in/out of focus, MUST gain focus
function! s:IDE_SaveProjectAndExit()
	call s:IDE_TraceLog("IDE_SaveProjectAndExit()")
	call s:IDE_GainFocus()
	call s:IDE_SaveProject()
	call s:IDE_Exit()
endfunction
">>>
" === IDE_ReleaseAll() ===================================================<<<
" === could be in or out of focus
function! s:IDE_ReleaseAll()
	setlocal modifiable
	call s:IDE_ReleaseCommands()
	call s:IDE_ReleaseSyntax()
	call s:IDE_ReleaseBuffer()
	unlet! s:IDE_ProjectSyn s:IDE_Launched s:IDE_File s:IDE_Project s:IDE_BufferMap s:IDE_PendingUpdate
endfunction
">>>
" === IDE_ReleaseBuffer() ================================================<<<
" === Close the IDE window and adjust the Vim window width ================
function! s:IDE_ReleaseBuffer()
	call s:IDE_TraceLog('IDE_ReleaseBuffer()')
	call s:IDE_RemoveFileAutoCommands()
	call s:IDE_RevertWindowWidth()
	call s:IDE_ForceRemoveAllSign()
	call s:IDE_OtherPluginRelease()
	" Reset IDE state variables
	call s:IDE_VariableInitialization()
	if exists('s:IDE_isWindowInitialized')
		unlet s:IDE_isWindowInitialized
	endif
	set guitablabel=
	set guitabtooltip=
endfunction
">>>
" === IDE_OtherPluginRelease() ===========================================<<<
function! s:IDE_OtherPluginRelease()
	" === Restore previous plugin settings ==================================<<<
	if exists("g:Tlist_Use_Right_Window")
		let g:Tlist_Use_Right_Window = s:Tlist_previous_setting
		unlet s:Tlist_previous_setting
	endif
	">>>
	silent! autocmd! IDEexSearch
endfunction
">>>
" === IDE_ReleaseSyntax() ================================================<<<
function! s:IDE_ReleaseSyntax()
	" Clear all the highlights
	match none
	silent! syntax clear IDEDescriptionDir
	silent! syntax clear IDEDescription
	silent! syntax clear IDEDescription
	silent! syntax clear IDEDirectory
	silent! syntax clear IDEDirectory
	silent! syntax clear IDEScriptinout
	silent! syntax clear IDEScriptinout
	silent! syntax clear IDEComment
	silent! syntax clear IDECD
	silent! syntax clear IDEFilterEntry
	silent! syntax clear IDEFilter
	silent! syntax clear IDEFlagsEntry
	silent! syntax clear IDEFlags
	silent! syntax clear IDEFlagsValues
	silent! syntax clear IDEFlagsError
	silent! syntax clear IDEWhiteError
	silent! syntax clear IDEWhiteError
	silent! syntax clear IDEFilterError
	silent! syntax clear IDEFilterRegexp
	silent! syntax clear IDEHelp
	silent! syntax clear IDEDivider
	"silent! syntax clear IDEFoldText
endfunction
">>>
" === IDE_ReleaseCommands() ==============================================<<<
function! s:IDE_ReleaseCommands()
	" Remove the IDE autocommands
	silent! autocmd! IDEListAutoCmds
	" Delete defined commands
	delcommand IDEToggle
	delcommand IDEExit
	delcommand IDEOpen
	delcommand IDEClose
	delcommand IDESave
	delcommand IDELogon
	delcommand IDELogoff
	delcommand IDEShowlog
	delcommand IDEShowenv
	" === Remove Global mappings for Toggle =================================<<<
	if s:IDE_hasMapToggle && exists("g:IDE_MapProjectToggle") && g:IDE_MapProjectToggle != ''
		exe 'silent! unmap ' . g:IDE_MapProjectToggle
	endif
	">>>
	" === Remove Global Mappings for Make Entire ============================<<<
	"release
	if s:IDE_hasMapMake && exists("g:IDE_MapMakeMainTarget_1") && g:IDE_MapMakeMainTarget_1 != ''
		if hasmapto('<Plug>MakeMainTarget_1')
			exe 'nunmap  ' . g:IDE_MapMakeMainTarget_1
			exe 'unmap   ' . g:IDE_MapMakeMainTarget_1
			exe 'iunmap  ' . g:IDE_MapMakeMainTarget_1
		endif
	endif
	"debug
	if s:IDE_hasMapMake && exists("g:IDE_MapMakeMainTarget_2") && g:IDE_MapMakeMainTarget_2 != ''
		if hasmapto('<Plug>MakeMainTarget_2')
			exe 'nunmap  ' . g:IDE_MapMakeMainTarget_2
			exe 'unmap   ' . g:IDE_MapMakeMainTarget_2
			exe 'iunmap  ' . g:IDE_MapMakeMainTarget_2
		endif
	endif
	"clean
	if s:IDE_hasMapMake && exists("g:IDE_MapMakeMainTarget_3") && g:IDE_MapMakeMainTarget_3 != ''
		if hasmapto('<Plug>MakeMainTarget_3')
			exe 'nunmap  ' . g:IDE_MapMakeMainTarget_3
			exe 'unmap   ' . g:IDE_MapMakeMainTarget_3
			exe 'iunmap  ' . g:IDE_MapMakeMainTarget_3
		endif
	endif
	">>>
	" === Remove Global Mappings for Make Current ===========================<<<
	"release
	if s:IDE_hasMapMake && exists("g:IDE_MapMakeThisTarget_1") && g:IDE_MapMakeThisTarget_1 != ''
		if hasmapto('<Plug>MakeThisTarget_1')
			exe 'nunmap  ' . g:IDE_MapMakeThisTarget_1
			exe 'unmap   ' . g:IDE_MapMakeThisTarget_1
			exe 'iunmap  ' . g:IDE_MapMakeThisTarget_1
		endif
	endif
	"debug
	if s:IDE_hasMapMake && exists("g:IDE_MapMakeThisTarget_2") && g:IDE_MapMakeThisTarget_2 != ''
		if hasmapto('<Plug>MakeThisTarget_2')
			exe 'nunmap  ' . g:IDE_MapMakeThisTarget_2
			exe 'unmap   ' . g:IDE_MapMakeThisTarget_2
			exe 'iunmap  ' . g:IDE_MapMakeThisTarget_2
		endif
	endif
	"clean
	if s:IDE_hasMapMake && exists("g:IDE_MapMakeThisTarget_3") && g:IDE_MapMakeThisTarget_3 != ''
		if hasmapto('<Plug>MakeThisTarget_3')
			exe 'nunmap  ' . g:IDE_MapMakeThisTarget_3
			exe 'unmap   ' . g:IDE_MapMakeThisTarget_3
			exe 'iunmap  ' . g:IDE_MapMakeThisTarget_3
		endif
	endif
	">>>
endfunction
">>>
" === Buffer start
" === IDE_SetupBuffer() ==================================================<<<
" === Open and refresh the IDE window ====================================
function! s:IDE_SetupBuffer()
	call s:IDE_TraceLog('IDE_SetupBuffer()')
	let l:retval = 0
	" If the window is open, jump to it
	if s:IDE_Buffer == -1
		if s:IDE_AppName == "winmanager"
			" IDE plugin is no longer part of the winmanager app
			let s:IDE_AppName = "none"
		endif
		if !filereadable(g:IDE_Title)
			" Open the IDE window
			call s:IDE_CreateBuffer()
			let l:retval = 1
		else
			call s:IDE_ErrorMsg("Cannot create IDE buffer. Check you don't have a file named \"".g:IDE_Title."\" on your folder.")
		endif
	else
		call s:IDE_ErrorMsg("IDE buffer already exits. No double dispatching allowed.")
	endif
	return l:retval
endfunction
">>>
" === IDE_CreateBuffer() =================================================<<<
" === Create a new IDE window. If it is already open, jump to it =========
function! s:IDE_CreateBuffer()
	call s:IDE_TraceLog('IDE_CreateBuffer()')
	" If the window is open, jump to it
	let l:IDE_winnum = bufwinnr(g:IDE_Title)
	if l:IDE_winnum != -1
		" Jump to the existing window
		if winnr() != l:IDE_winnum
			exe l:IDE_winnum . 'wincmd w'
		endif
		return
	endif
	" If used with winmanager don't open windows. Winmanager will handle
	" the window/buffer management
	if s:IDE_AppName == "winmanager"
		return
	endif
	" Record window width
	call s:IDE_RecPreWindowWidth()
	" If the tag listing temporary buffer already exists, then reuse it.
	" Otherwise create a new buffer
	if s:IDE_Buffer == -1
		" Create a new buffer
		let l:wcmd = g:IDE_Title
	else
		" Edit the existing buffer
		call s:IDE_WarnMsg("Reusing existing buffer ".g:IDE_Title)
		let l:wcmd = '+buffer' . s:IDE_Buffer
	endif
	" Create the IDE window
	exe 'silent! ' . s:IDE_cmdWindowPlace . ' ' . s:IDE_userWindowWidth . 'split ' . l:wcmd
	" Save the new window position
	call s:IDE_RecWindowWidth()
	let s:IDE_Buffer = bufnr(g:IDE_Title)
	" Initialize the IDE window
	call s:IDE_InitializeBuffer()
	call s:IDE_InitializeHiglightGroups()
	call s:IDE_InitializeCommands()
endfunction
">>>
" === IDE_OtherPluginSetup() =============================================<<<
" === Interact with other plugins
function! s:IDE_OtherPluginSetup()
	if exists("g:showmarks_enable")
		"Disable showmarks for cosmetic appeal
		let b:showmarks_include = ""
	endif
	if exists("g:Tlist_Use_Right_Window")
		"Overrule tag list positions, place opposite of the IDE
		let s:Tlist_previous_setting = g:Tlist_Use_Right_Window
		if s:IDE_isAtRightWindow
			let g:Tlist_Use_Right_Window = 0
		else
			let g:Tlist_Use_Right_Window = 1
		endif
	endif
	if exists("g:SrcExpl_pluginList")
		"Augment the plugin list of the source explorer to recognize the IDE
		let l:add = 1
		for item in g:SrcExpl_pluginList
			if g:IDE_Title ==# item
				let l:add = 0
			endif
		endfor
		if l:add
			call insert(g:SrcExpl_pluginList,g:IDE_Title)
		endif
		let l:fullname = fnamemodify(bufname(g:IDE_Title),":p")
		let l:relativename = fnamemodify(l:fullname,":~")
		call insert(g:SrcExpl_pluginList,l:relativename)
		call insert(g:SrcExpl_pluginList,l:fullname)
	endif
	if exists('g:loaded_exscript')
		"Workaround the recording of buffers for ex-global-search, as to avoid
		"being the target buffer for its edit.
		"This could be much more elegant if the ex-global-search had a variable to define its edit style.
		augroup IDEexSearch
			autocmd!
			autocmd BufEnter,WinEnter __ex*,<ex_filetype> call g:ex_RecordCurrentBufNum()
		augroup end
	endif
endfunction
">>>
" === IDE_InitializeBuffer() =============================================<<<
" === We are in the IDE buffer
function! s:IDE_InitializeBuffer()
	if bufnr('%')!=s:IDE_Buffer
		return
	endif
	call s:IDE_TraceLog('IDE_InitializeBuffer()')
	" The 'readonly' option should not be set for the IDE buffer.
	" If Vim is started as "view/gview" or if the ":view" command is
	" used, then the 'readonly' option is set for all the buffers.
	" Unset it for the IDE buffer
	setlocal noreadonly
	" Set the IDE buffer filetype to IDE
	setlocal filetype=IDE
	setlocal buftype=nowrite
	setlocal nospell
	setlocal nobuflisted
	set guitablabel=%{IDE_ProjectTabLabel()}
	set guitabtooltip=%{IDE_ProjectTabToolTip()}
	" Setup balloon evaluation to display tag prototype
	"if v:version >= 700 && has('balloon_eval')
	"	setlocal balloonexpr=IDE_Ballon_Expr()
	"	set ballooneval
	"endif
	call s:IDE_OtherPluginSetup()
endfunction
">>>
" === IDE_InitializeHiglightGroups() =====================================<<<
" === We are in the IDE buffer
function! s:IDE_InitializeHiglightGroups()
	" Define IDE window element highlighting
	if s:IDE_doSyntaxOnWindowIDE
		syntax match IDEDescriptionDir '^\s*.\{-}=\s*\(\\ \|\f\|:\|"\)\+' contains=IDEDescription,IDEWhiteError
		syntax match IDEDescription    '\<.\{-}='he=e-1,me=e-1         contained nextgroup=IDEDirectory contains=IDEWhiteError
		syntax match IDEDescription    '{\|}'
		syntax match IDEDirectory      '=\(\\ \|\f\|:\)\+'             contained
		syntax match IDEDirectory      '=".\{-}"'                      contained
		syntax match IDEScriptinout    '\<in\s*=\s*\(\\ \|\f\|:\|"\)\+' contains=IDEDescription,IDEWhiteError
		syntax match IDEScriptinout    '\<out\s*=\s*\(\\ \|\f\|:\|"\)\+' contains=IDEDescription,IDEWhiteError
		syntax match IDEComment        '#.*'
		syntax match IDECD             '\<CD\s*=\s*\(\\ \|\f\|:\|"\)\+' contains=IDEDescription,IDEWhiteError
		syntax match IDEFilterEntry    '\<filter\s*=.*"'               contains=IDEWhiteError,IDEFilterError,IDEFilter,IDEFilterRegexp
		syntax match IDEFilter         '\<filter='he=e-1,me=e-1        contained nextgroup=IDEFilterRegexp,IDEFilterError,IDEWhiteError
		syntax match IDEFlagsEntry     '\<flags\s*=\( \|[^ ]*\)'       contains=IDEFlags,IDEWhiteError
		syntax match IDEFlags          '\<flags'                       contained nextgroup=IDEFlagsValues,IDEWhiteError
		syntax match IDEFlagsValues    '=[^ ]* 'hs=s+1,me=e-1          contained contains=IDEFlagsError
		syntax match IDEFlagsError     '[^rtTsSwl= ]\+'                contained
		syntax match IDEWhiteError     '=\s\+'hs=s+1                   contained
		syntax match IDEWhiteError     '\s\+='he=e-1                   contained
		syntax match IDEFilterError    '=[^"]'hs=s+1                   contained
		syntax match IDEFilterRegexp   '=".*"'hs=s+1                   contained
		syntax match IDEHelp 		   '^".*'
		syntax match IDEHelpType       '^\[.*\]'
		syntax match IDEDivider        '^[%]*$'
		"syntax match IDEFoldText       '^[^=]\+{'

		highlight def link IDEDescription  Identifier
		highlight def link IDEScriptinout  Identifier
		highlight def link IDEComment      Comment
		highlight def link IDEFilter       Identifier
		highlight def link IDEFlags        Identifier
		highlight def link IDEDirectory    Constant
		highlight def link IDEFilterRegexp String
		highlight def link IDEFlagsValues  String
		highlight def link IDEWhiteError   Error
		highlight def link IDEFlagsError   Error
		highlight def link IDEFilterError  Error
		highlight def link IDEHelp         IDEHL_Help
		highlight def link IDEHelpType     IDEHL_HelpType
		highlight def link IDEDivider      IDEHL_Divider
		"highlight def link IDEFoldText    IDEHL_Folded
	endif
	" Folding related settings
	call s:FoldTextSetup()
endfunction
">>>
" === IDE_InitializeCommands() ===========================================<<<
function! s:IDE_InitializeCommands()
	" Setup the cpoptions properly for the maps to work
	let l:old_cpoptions = &cpoptions
	set cpoptions&vim
	" === Global Commands added to Vim =================================<<<
	command! -nargs=0 -bang IDEExit call s:IDE_ExitCmd("cmd"."<bang>")
	command! -nargs=0 -bang -bar IDESave call s:IDE_SaveProject()
	command! -nargs=0 -bar IDEToggle call s:IDE_Toggle()
	command! -nargs=0 -bar IDEOpen call s:IDE_GainFocus()
	command! -nargs=0 -bang -bar IDEClose call s:IDE_LoseFocus()
	" Commands for enabling/disabling log and to display log messages
	command! -nargs=? -complete=file -bar IDELogon call s:IDE_LogEnable(<q-args>)
	command! -nargs=0 -bar IDELogoff call s:IDE_LogDisable()
	command! -nargs=0 -bar IDEShowlog call s:IDE_ShowLog()
	command! -nargs=0 -bar IDEShowenv call s:IDE_ShowEnvironment()
	" Commands for updating the syntax highlight
	if s:IDE_isSyntaxCapable != 0
		command! -nargs=0 -bang IDESyntax call s:IDE_UpdateSyntaxFile("cmd"."<bang>")
	endif
	">>>
	" === Global Mappings for Toggle ===================================<<<
	if s:IDE_hasMapToggle && exists("g:IDE_MapProjectToggle") && g:IDE_MapProjectToggle != ''
		exe 'map <silent> ' . g:IDE_MapProjectToggle . ' :IDEToggle<CR>'
		exe 'noremap <silent> ' . g:IDE_MapProjectToggle . ' :IDEToggle<CR>'
	endif
	">>>
	" === Global Mappings for Make Main Project ======================<<<
	if s:IDE_hasMapMake
		"Target_1 i.e: release
		if exists("g:IDE_MapMakeMainTarget_1") && g:IDE_MapMakeMainTarget_1 != '' && !hasmapto('<Plug>MakeMainTarget_1')
			exe 'nmap <silent> ' . g:IDE_MapMakeMainTarget_1 . ' <Plug>MakeMainTarget_1'
			exe 'map  <silent> ' . g:IDE_MapMakeMainTarget_1 . ' <Plug>MakeMainTarget_1'
			exe 'imap <silent> ' . g:IDE_MapMakeMainTarget_1 . ' <ESC> <Plug>MakeMainTarget_1 <CR>i'
		endif
		"Target_2 i.e: debug
		if exists("g:IDE_MapMakeMainTarget_2") && g:IDE_MapMakeMainTarget_2 != '' && !hasmapto('<Plug>MakeMainTarget_2')
			exe 'nmap <silent> ' . g:IDE_MapMakeMainTarget_2 . ' <Plug>MakeMainTarget_2'
			exe 'map  <silent> ' . g:IDE_MapMakeMainTarget_2 . ' <Plug>MakeMainTarget_2'
			exe 'imap <silent> ' . g:IDE_MapMakeMainTarget_2 . ' <ESC> <Plug>MakeMainTarget_2 <CR>i'
		endif
		"Target_3 i.e: clean
		if exists("g:IDE_MapMakeMainTarget_3") && g:IDE_MapMakeMainTarget_3 != '' && !hasmapto('<Plug>MakeMainTarget_3')
			exe 'nmap <silent> ' . g:IDE_MapMakeMainTarget_3 . ' <Plug>MakeMainTarget_3'
			exe 'map  <silent> ' . g:IDE_MapMakeMainTarget_3 . ' <Plug>MakeMainTarget_3'
			exe 'imap <silent> ' . g:IDE_MapMakeMainTarget_3 . ' <ESC> <Plug>MakeMainTarget_3 <CR>i'
		endif
	endif
	">>>
	" === Global Mappings for Make Current/This Project =====================<<<
	if s:IDE_hasMapMake
		"Target_1 i.e: release
		if exists("g:IDE_MapMakeThisTarget_1") && g:IDE_MapMakeThisTarget_1 != '' && !hasmapto('<Plug>MakeThisTarget_1')
			exe 'nmap <silent> ' . g:IDE_MapMakeThisTarget_1 . ' <Plug>MakeThisTarget_1'
			exe 'map  <silent> ' . g:IDE_MapMakeThisTarget_1 . ' <Plug>MakeThisTarget_1'
			exe 'imap <silent> ' . g:IDE_MapMakeThisTarget_1 . ' <ESC> <Plug>MakeThisTarget_1 <CR>i'
		endif
		"Target_2 i.e: debug
		if exists("g:IDE_MapMakeThisTarget_2") && g:IDE_MapMakeThisTarget_2 != '' && !hasmapto('<Plug>MakeThisTarget_2')
			exe 'nmap <silent> ' . g:IDE_MapMakeThisTarget_2 . ' <Plug>MakeThisTarget_2'
			exe 'map  <silent> ' . g:IDE_MapMakeThisTarget_2 . ' <Plug>MakeThisTarget_2'
			exe 'imap <silent> ' . g:IDE_MapMakeThisTarget_2 . ' <ESC> <Plug>MakeThisTarget_2 <CR>i'
		endif
		"Target_3 i.e: clean
		if exists("g:IDE_MapMakeThisTarget_3") && g:IDE_MapMakeThisTarget_3 != '' && !hasmapto('<Plug>MakeThisTarget_3')
			exe 'nmap <silent> ' . g:IDE_MapMakeThisTarget_3 . ' <Plug>MakeThisTarget_3'
			exe 'map  <silent> ' . g:IDE_MapMakeThisTarget_3 . ' <Plug>MakeThisTarget_3'
			exe 'imap <silent> ' . g:IDE_MapMakeThisTarget_3 . ' <ESC> <Plug>MakeThisTarget_3 <CR>i'
		endif
	endif
	">>>
	" === Command Mappings =============================================<<<
	cnoremap <buffer> quit  <CR>:IDEClose
	cnoremap <buffer> wq    <CR>:IDEExit
	cnoremap <buffer> write <CR>:IDESave
	cabbrev q quit
	cabbrev w write
	"cabbrev q <c-R>=((getcmdtype()==':' && getcmdpos()==1) ? 'quit' : 'q')<cr>
	"cabbrev w <c-R>=((getcmdtype()==':' && getcmdpos()==1) ? 'write' : 'w')<cr>
	">>>
	" === Buffer Mappings ==============================================<<<
	nnoremap <buffer> <silent> <Return>   		:call <SID>DoFoldOrOpenEntry(g:IDE_DefaultOpenMethod)<CR>
	nnoremap <buffer> <silent> <S-Return> 		:call <SID>DoFoldOrOpenEntry(g:IDE_ShiftOpenMethod)<CR>
	exe 'nnoremap <buffer> <silent> ' . g:IDE_Info						. ' :call <SID>IDE_ShowInfo_atline()<CR>'
	exe 'nnoremap <buffer> <silent> ' . g:IDE_InfoDetailed 				. ' :call <SID>IDE_ShowInfoDetailed_atline()<CR>'
	exe 'nnoremap <buffer> <silent> ' . g:IDE_LoadAll 					. ' :call <SID>IDE_LoadAllFilesInProject_atline(0)<CR>'
	exe 'nnoremap <buffer> <silent> ' . g:IDE_LoadAllRecursive  		. ' :call <SID>IDE_LoadAllFilesInProject_atline(1)<CR>'
	exe 'nnoremap <buffer> <silent> ' . g:IDE_WipeAll 					. ' :call <SID>IDE_WipeAllFilesInProject_atline(0)<CR>'
	exe 'nnoremap <buffer> <silent> ' . g:IDE_WipeAllRecursive 			. ' :call <SID>IDE_WipeAllFilesInProject_atline(1)<CR>'
	exe 'nnoremap <buffer> <silent> ' . g:IDE_GrepAll 					. ' :call <SID>IDE_GrepAllFilesInProject_atline(0,"")<CR>'
	exe 'nnoremap <buffer> <silent> ' . g:IDE_GrepAllRecursive 			. ' :call <SID>IDE_GrepAllFilesInProject_atline(1,"")<CR>'
	exe 'nnoremap <buffer> <silent> ' . g:IDE_Create 					. ' :call <SID>IDE_CreateEntriesFrom(0)<CR>'
	exe 'nnoremap <buffer> <silent> ' . g:IDE_CreateRecursive 			. ' :call <SID>IDE_CreateEntriesFrom(1)<CR>'
	exe 'nnoremap <buffer> <silent> ' . g:IDE_RefreshContent 			. ' :call <SID>IDE_RefreshEntriesFrom(0,1)<CR>'
	exe 'nnoremap <buffer> <silent> ' . g:IDE_RefreshContentRecursive 	. ' :call <SID>IDE_RefreshEntriesFrom(1,1)<CR>'
	exe 'nnoremap <buffer> <silent> ' . g:IDE_SortContent 				. ' :call <SID>IDE_RefreshEntriesFrom(0,0)<CR>'
	exe 'nnoremap <buffer> <silent> ' . g:IDE_SortContentRecursive 		. ' :call <SID>IDE_RefreshEntriesFrom(1,0)<CR>'
	" Mouse mappings
	nnoremap <buffer> <silent> <2-LeftMouse>   	:call <SID>DoFoldOrOpenEntry(g:IDE_DefaultOpenMethod)<CR>
	nnoremap <buffer> <silent> <S-2-LeftMouse> 	:call <SID>DoFoldOrOpenEntry(g:IDE_ShiftOpenMethod)<CR>
	nnoremap <buffer> <silent> <S-LeftMouse>   	<LeftMouse>
	nmap     <buffer> <silent> <C-2-LeftMouse> 	<C-Return>
	nnoremap <buffer> <silent> <C-LeftMouse>   	<LeftMouse>
	nnoremap <buffer> <silent> <3-LeftMouse>  	<Nop>
	nmap     <buffer> <silent> <RightMouse>   	<space>
	nmap     <buffer> <silent> <2-RightMouse> 	<space>
	nmap     <buffer> <silent> <3-RightMouse> 	<space>
	nmap     <buffer> <silent> <4-RightMouse> 	<space>
	nmap 	 <buffer> <silent> <C-a>			:call <SID>IDE_AddEntry(line('.'))<CR>
	nmap 	 <buffer> <silent> dd				:call <SID>IDE_RemoveEntry(line('.'))<CR>
	" <space> mapping
	nnoremap <buffer> <silent> <space>  		:call <SID>IDE_ResizeWindow()<CR>
	" <C-up> <C-down> mapping
	nnoremap <buffer> <silent> <C-Up>   		:call <SID>MoveUp()<CR>
	nnoremap <buffer> <silent> <C-Down> 		:call <SID>MoveDown()<CR>
	nnoremap <buffer> <silent> i 				:silent call <SID>IDE_Modify(line('.'))<CR>i
	let k=1
	while k < 10
		exe 'nnoremap <buffer> <LocalLeader>'.k.'  :call <SID>Spawn('.k.')<CR>'
		exe 'nnoremap <buffer> <LocalLeader>f'.k.' :call <SID>SpawnAll(0, '.k.')<CR>'
		exe 'nnoremap <buffer> <LocalLeader>F'.k.' :call <SID>SpawnAll(1, '.k.')<CR>'
		let k=k+1
	endwhile
	nnoremap <buffer>          <LocalLeader>0 	:call <SID>ListSpawn("")<CR>
	nnoremap <buffer>          <LocalLeader>f0 	:call <SID>ListSpawn("_fold")<CR>
	nnoremap <buffer>          <LocalLeader>F0 	:call <SID>ListSpawn("_fold")<CR>
	" This is to avoid changing the buffer, but it is not fool-proof.
	nnoremap <buffer> <silent> <C-^> <Nop>
	" Fold mappings
	nnoremap <buffer> <silent> + 				:silent! foldopen<CR>
	nnoremap <buffer> <silent> - 				:silent! foldclose<CR>
	nnoremap <buffer> <silent> * 				:silent! %foldopen!<CR>
	nnoremap <buffer> <silent> = 				:silent! %foldclose<CR>
	nnoremap <buffer> <silent> <kPlus> 			:silent! foldopen<CR>
	nnoremap <buffer> <silent> <kMinus> 		:silent! foldclose<CR>
	nnoremap <buffer> <silent> <kMultiply> 		:silent! %foldopen!<CR>
	" Help & close mappings
	nnoremap <buffer> <silent> <F1> 			:call <SID>IDE_ToggleHelp()<CR>
	inoremap <buffer> <silent> <F1>  	   <C-o>:call <SID>IDE_ToggleHelp()<CR>
	nnoremap <buffer> <silent> <F2> 			:call <SID>IDE_SaveProject()<CR>
	nnoremap <buffer> <silent> <S-F2> 			:call <SID>IDE_SaveProjectAndExit()<CR>
	nnoremap <buffer> <silent> <C-F2> 			:call <SID>IDE_SafeExit()<CR>
	nnoremap <buffer> <silent> q 				:call <SID>IDE_ToggleClose()<CR>
	" Test mapings
	"nnoremap <buffer> <silent> <F11>    		:call <SID>IDE_ConstructProject(line('.'),'')<CR>
	" nnoremap <buffer> <silent> <C-F11>   		:call <SID>IDE_GenerateFileMap(line('.'))<CR>
	">>>
	" === Autocommands =================================================<<<
	augroup IDEListAutoCmds
		autocmd!
		" Autocommands to clean up if we do a buffer wipe
		" These don't work unless we substitute \ for / for Windows
		autocmd BufWipeout __IDE_Project__ au! * __IDE_Project__
		autocmd BufWipeout __IDE_Project__ call s:IDE_WipeoutExit_au()
		if s:IDE_isEnableSignMarks
			autocmd Bufwipeout __IDE_Project__ call s:IDE_RemoveAllSign_au()
			autocmd BufEnter __IDE_Project__  call s:IDE_PendingUpdate_au()
		endif
		"autocmd WinLeave __IDE_Project__ au! * __IDE_Project__
		autocmd WinLeave __IDE_Project__ call s:IDE_FoldLeave_au()
		autocmd WinLeave __IDE_Project__ call s:DoEnsurePlacementSize_au()
		" Autocommands to keep the window the specified size
		autocmd WinLeave * call s:IDE_RecordLastBuffer_au()
		autocmd BufLeave __IDE_Project__ call s:IDE_RecordWindowSize_au()
		"autocmd BufEnter __IDE_Project__ au! * __IDE_Project__
		autocmd BufEnter __IDE_Project__ call s:DoWindowSetupAndSplit_au()
		autocmd InsertEnter __IDE_Project__ call s:IDE_BeforeEdit_au()
		autocmd InsertLeave __IDE_Project__ call s:IDE_AfterEdit_au()
		autocmd CursorHold __IDE_Project__ call s:IDE_ShowInfo_atline()
		" Adjust the Vim window width when IDE window is closed
		"autocmd BufUnload __IDE_Project__ call s:IDE_ReleaseBuffer()
		"autocmd BufUnload * call s:IDE_CloseTabIfOnlyWindow_au()
		"if s:IDE_AppName != "winmanager" && !s:IDE_updateWinManagerAlways
		"autocmd BufEnter * call s:IDE_Refresh()
		"endif
	augroup end
	">>>
	"	" Restore the previous cpoptions settings
	let &cpoptions = l:old_cpoptions
endfunction
">>>
" === IDE_GetConsistentFileName(file) ====================================<<<
function! s:IDE_GetConsistentFileName(name)
	"call s:IDE_TraceLog('IDE_GetConsistentFileName('.a:name.')')
	let l:bufname = expand(a:name, 0)
	let l:bufname = escape(l:bufname, '\')
	let l:bufname = substitute(l:bufname, '\\', '/', 'g')
	"let l:bufname = escape(l:bufname, ' %#')
	let l:bufname = substitute(l:bufname,'\/\.\/','\/','g')
	let l:bufname = resolve(l:bufname)
	let l:bufname = simplify(l:bufname)
	return l:bufname
endfunction
">>>
" === IDE_LoadProject() ==================================================<<<
" === Project Load File ==================================================
function s:IDE_LoadProject()
	call s:IDE_TraceLog('IDE_LoadProject()')
	"store the current buffer number
	let l:curbufnr = bufnr('%')
	call s:IDE_GainFocusIfOpenInWindows()
	" Set report option to a huge value to prevent informational messages
	" while deleting the lines
	let l:old_report = &report
	set report=99999
	" Mark the buffer as modifiable
	setlocal modifiable
	silent! exe "normal! G"
	" Make sure the project read does not become an alternate buffer
	let l:old_cpoptions = &cpoptions
	set cpoptions-=a
	exe "silent read ".s:IDE_Launched['file_esc']
	let &cpoptions = l:old_cpoptions
	" Remove any empty line, comments can be kept
	silent! exe "silent! %s/^\s*\\n//g"
	" Mark the buffer as not modifiable
	setlocal nomodifiable
	let l:sitonline = s:brief_help_size+1
	silent! exe l:sitonline
	let s:IDE_ProjectEND = s:IDE_ConstructProject(l:sitonline,'')
	call s:IDE_ConstructProjectData()
	silent! exe l:sitonline
	let l:lineis = getline(l:sitonline)
	let s:IDE_ProjectName = s:IDE_GetProjectName(l:lineis,l:sitonline)
	"jump back to 'current buffer'
	let l:winnum = bufwinnr(l:curbufnr)
	if winnr() != l:winnum
		exe l:winnum . 'wincmd w'
	endif
	" Restore the report option
	let &report = l:old_report
	call s:IDE_LogMsg('project-file "'.s:IDE_Launched['name'].'" has been loaded into the ide.')
endfunction
">>>
" === IDE_Initialize() ===================================================<<<
function! s:IDE_Initialize(filename,fullname)
	call s:IDE_DisplayHelp()
	call s:DoWindowSetupAndSplit()
	let s:IDE_Launched['name'] = a:filename
	let s:IDE_Launched['file'] = s:IDE_GetConsistentFileName(a:fullname)
	let s:IDE_Launched['file_esc'] = escape(s:IDE_GetConsistentFileName(a:fullname),' #%')
	let s:IDE_Launched['dir'] = getcwd()
	let s:IDE_Launched['dir_esc'] = escape(getcwd(),' #%')
	call s:IDE_LoadProject()
	call s:IDE_StartSyntax()
	" we have finish loading the project, the current project in the IDE is
	" an image of the project in file, so set the IDE buffer to not modified
	call setbufvar(g:IDE_Title, '&modified', '0')
endfunction
">>>
" === IDE_Load(...) ======================================================<<<
" === Project Load =======================================================
function! s:IDE_Load(...)
	if a:0 == 0 || a:1 == ''
		call s:IDE_WarnMsg('Usage: IDE <project_name>')
		return
	endif
	let l:filename = fnamemodify(a:1, ':t')
	let l:fullname = fnamemodify(a:1, ':p')
	if !filereadable(l:fullname)
		call s:IDE_ErrorMsg('Unable to open project-file ' . l:filename)
		return
	endif
	if exists("g:IDE_Title") && bufnr(g:IDE_Title) == -1
		" the buffer has been wipe out by the user (or by a command given by the user)
		unlet g:IDE_Title
		unlet! s:IDE_ProjectSyn s:IDE_Launched s:IDE_File s:IDE_Project s:IDE_BufferMap s:IDE_PendingUpdate
		call s:IDE_WarnMsg("FYI The autocommands were dissabled and then the IDE was wipeout")
	endif
	if !exists("g:IDE_Title")
		" starting the IDE (not being reloaded)
		call s:IDE_StartDebug()
		" Do not change the name of the IDE title variable. The winmanager
		" plugin relies on this name to determine the title for the IDE plugin.
		let g:IDE_Title = "__IDE_Project__"
		call s:IDE_VariableInitialization()
		let l:ready = s:IDE_SetupBuffer()
		if l:ready
			call s:IDE_Initialize(l:filename,l:fullname)
		else
			call s:IDE_InfoMsg("Cowardly refusing to load project-file ".s:IDE_Launched['name']." as vim refused to create the buffer")
			unlet g:IDE_Title
		endif
	else
		" The IDE has been running, we are about to load a new project
		if exists("s:IDE_Launched")
			if l:fullname != s:IDE_Launched['file']
				if l:filename == s:IDE_Launched['name']
					let l:choice = confirm('Do you want to close the ide-project '.s:IDE_Launched['file_esc']."\n".'and load '.l:fullname.' ?', "&YES\n&NO", 1)
				else
					let l:choice = confirm('Do you want to close the ide-project '.s:IDE_Launched['name']."\n".'and load '.l:filename.' ?', "&YES\n&NO", 1)
				endif
				if l:choice!=1
					return
				endif
			else
				call s:IDE_InfoMsg('Reloading ide-project '.l:filename)
			endif
			"Gain Focus!!
			let l:status = s:IDE_GainFocus()
			if (l:status==1)
				call s:IDE_RemoveFileAutoCommands()
				call s:IDE_ForceRemoveAllSign()
				if s:IDE_isModified
					let l:choice = confirm('Do you want to save the changes made to '.s:IDE_Launched['name'].' ?', "&YES\n&NO", 1)
					if l:choice==1
						call s:IDE_SaveProject()
					endif
				endif
				" Remove all file content
				setlocal modifiable
				exe 'silent! 1,$ delete _'
				call s:IDE_VariableInitialization()
				call s:IDE_Initialize(l:filename,l:fullname)
				setlocal nomodifiable
			else
				if a:0 == 1
					call s:IDE_WarnMsg("The IDE was left in an unknown state, attempting phoenex ...")
					call s:IDE_Exit()
					call s:IDE_Load(a:1,"re-entry")
				else
					call s:IDE_ErrorMsg("IDE cannot recover, please report the problem ...")
				endif
			endif
		else
			call s:IDE_ErrorMsg("The ide-project has been wipe out!")
		endif
	endif
endfunction
">>>
" === Buffer Tracking
" === IDE_GetID(line) ====================================================<<<
function s:IDE_GetID(line)
	let adjline=a:line
	if !s:IDE_isBriefHelp
		let adjline+=s:brief_help_size
		let adjline-=s:full_help_size
	endif
	return adjline
endfunction
">>>
" === IDE_GetLocation(line) ==============================================<<<
function s:IDE_GetLocation(id)
	let adjline=a:id
	if !s:IDE_isBriefHelp
		let adjline+=s:full_help_size
		let adjline-=s:brief_help_size
	endif
	return adjline
endfunction
">>>
" === IDE_TrackProjectChanges_au() =======================================<<<
function! s:IDE_TrackProjectChanges_au()
	call s:IDE_TraceLog("IDE_TrackProjectChanges()")
	let s:IDE_syntaxCounter=s:IDE_syntaxCounter+1
	if(s:IDE_syntaxCounter == s:IDE_syntaxThreshold)
		let s:IDE_syntaxCounter=0
		let s:IDE_syntaxUpdate += 1
	endif
endfunction
">>>
" === IDE_UpdateFileMap() ================================================<<<
function! s:IDE_UpdateFileMap()
	if s:IDE_isBriefHelp
		let l:sitonline = s:brief_help_size+1
	else
		let l:sitonline = s:full_help_size+1
	endif
	unlet s:IDE_File
	unlet s:IDE_Project
	unlet s:IDE_BufferMap
	let s:IDE_File = {}
	let s:IDE_Project = {}
	let s:IDE_BufferMap = {}
	let s:IDE_ProjectEND = s:IDE_ConstructProject(l:sitonline,'')
	call s:IDE_ConstructProjectData()
endfunction
">>>
" === IDE_BeforeEdit() ===================================================<<<
function! s:IDE_BeforeEdit()
	setlocal modifiable
	if s:IDE_isEnableSignMarks
		call s:IDE_ForceRemoveAllSign()
	endif
endfunction
">>>
" === IDE_AfterEdit() ====================================================<<<
function! s:IDE_AfterEdit()
	call s:IDE_UpdateFileMap()
	if s:IDE_isEnableSignMarks
		call s:IDE_ForceRedrawAllSign()
	endif
	setlocal nomodifiable
	let s:IDE_isModified = 1
endfunction
">>>
" === IDE_BeforeEdit_au() ================================================<<<
function! s:IDE_BeforeEdit_au()
	call s:IDE_BeforeEdit()
	setlocal nocursorline
	let s:IDE_isInInsert = 1
endfunction
">>>
" === IDE_AfterEdit_au() =================================================<<<
function! s:IDE_AfterEdit_au()
	call s:IDE_AfterEdit()
	setlocal cursorline
	let s:IDE_isInInsert = 0
endfunction
">>>
" === Buffer Visualization in Window
" === IDE_isLastBufferInWindow() =========================================<<<
function! s:IDE_isLastBufferInWindow()
	call s:IDE_TraceLog("IDE_isLastBufferInWindow()")
	if winbufnr(2) == -1
		return 1
	endif
	return 0
endfunction
">>>
" === IDE_CloseTabIfOnlyWindow_au() ======================================<<<
" === If the 'IDE_CloseTabIfOnlyWindow_au' option is set, then exit Vim if only the IDE window is present.
function! s:IDE_CloseTabIfOnlyWindow_au()
	call s:IDE_TraceLog("IDE_CloseTabIfOnlyWindow_au()")
	if winbufnr(0) == s:IDE_Buffer
		return
	endif
	" Before quitting Vim, delete the IDE buffer so that
	" the '0 mark is correctly set to the previous buffer.
	if v:version >= 700
		if winbufnr(2) == -1
			let l:first_tabpage = 1
			let l:current_tabpage = tabpagenr()
			let last_tabpage = tabpagenr('$')
			if tabpagenr('$') == l:first_tabpage
				" Only one tag page is present
				call s:IDE_WarnMsg("Last window.")
			else
				" More than one tab page is present. Close only the current tab page
				let l:close_tabpage = l:current_tabpage
				let l:tab_cmd = "tabprevious"
				if l:current_tabpage == l:first_tabpage
					"move to right
					let l:tab_cmd = "tabnext"
				endif
				exe l:tab_cmd
				exe "tabclose ".l:close_tabpage
				return 1
			endif
		endif
	endif
	return 0
endfunction
">>>
" === IDE_GetWindowState() ===============================================<<<
" === return the state for the buffer name
"      Exist | Open | Focus
"  1.=   X   |  X   |   X    bufname is the current buffer in current window
"  2.=   X   |  X   |        bufname is in the window, but NOT the current buffer
"  3.=   X   |      |        bufname is NOT in the window, but exist
"  4.=       |      |        bufname does NOT exist
function! s:IDE_GetWindowState(bufname)
	call s:IDE_TraceLog('IDE_GetWindowState()')
	let l:IDE_winnum = bufwinnr(a:bufname)
	let l:retval = -1
	if l:IDE_winnum != -1
		if winnr() == l:IDE_winnum
			let l:retval = 1
			call s:IDE_Assert(bufnr(a:bufname)==s:IDE_Buffer,"It's not in focus")
		else
			let l:retval = 2
		endif
	else
		if bufnr(a:bufname) != -1
			let l:retval = 3
		else
			let l:retval = 4
		endif
	endif
	return l:retval
endfunction
">>>
" === IDE_GainFocusIfOpenInWindows() =====================================<<<
" === Goes from WindowState 2 to 1
function! s:IDE_GainFocusIfOpenInWindows()
	call s:IDE_TraceLog('IDE_GainFocusIfOpenInWindows()')
	let l:winnum = bufwinnr(g:IDE_Title)
	if l:winnum != -1
		if winnr() != l:winnum
			call s:IDE_ExeWithoutAucmds(l:winnum . 'wincmd w')
		endif
		return 1
	endif
	return 0
endfunction
">>>
" === IDE_GainFocus() ====================================================<<<
" === Goes from WindowState 3|2 to 1
function! s:IDE_GainFocus()
	call s:IDE_TraceLog('IDE_GainFocus()')
	let l:retval = s:IDE_GainFocusIfOpenInWindows()
	if l:retval == 0
		if s:IDE_Buffer != -1 && s:IDE_Buffer == bufnr(g:IDE_Title)
			call s:IDE_ToggleOpen()
			let l:retval = 1
		endif
	endif
	return l:retval
endfunction
">>>
" === IDE_LoseFocus() ====================================================<<<
" === Goes from WindowState 1|2 to 3
function! s:IDE_LoseFocus()
	call s:IDE_TraceLog('IDE_LoseFocus()')
	let l:retval = s:IDE_GainFocusIfOpenInWindows()
	if l:retval == 1
		call s:IDE_ToggleClose()
	endif
endfunction
">>>
" === IDE_ToggleClose() ==================================================<<<
" === assumes we are in focus!!, that is IDE_GetWindowState() == 1
function! s:IDE_ToggleClose()
	call s:IDE_TraceLog('IDE_ToggleClose()')
	silent! hide
endfunction
">>>
" === IDE_ToggleOpen() ===================================================<<<
" === assumes we are out of focus, and windows is close!!, that is IDE_GetWindowState() == 3
function! s:IDE_ToggleOpen()
	call s:IDE_TraceLog('IDE_ToggleOpen()')
	call s:IDE_Assert((s:IDE_GetWindowState(g:IDE_Title)==3),"Not out of focus and close")
	exe 'silent! '.s:IDE_cmdWindowPlace.' '.s:IDE_userWindowWidth.'split +buffer'.g:IDE_Title
	exe s:IDE_cmdLocate
	exe 'silent! vertical resize '.s:IDE_userWindowWidth
	setlocal nomodeline
endfunction
">>>
" === IDE_Toggle() =======================================================<<<
" === Open or close a IDE window =========================================
function! s:IDE_Toggle()
	call s:IDE_TraceLog('IDE_Toggle()')
	let l:win_state = s:IDE_GetWindowState(g:IDE_Title)
	if l:win_state == 1
		call s:IDE_ToggleClose()
		call s:IDE_RevertWindowWidth()
	elseif l:win_state == 2
		call s:IDE_GainFocusIfOpenInWindows()
		call s:IDE_ToggleClose()
		call s:IDE_RevertWindowWidth()
	elseif l:win_state == 3
		let l:idebuf = bufnr(g:IDE_Title)
		let l:current_buffer=bufnr("%")
		let l:current_tab=s:IDE_GetTabNbr(current_buffer)
		for i in range(tabpagenr("$"))
			let l:blist = tabpagebuflist(i + 1)
			if !empty(l:blist) && index(l:blist, l:idebuf) != -1
				let l:idetab=  i + 1
				silent exe "silent! ". idetab . "tabnext"
				silent exe "silent! " . s:GetWinNbr(idetab, idebuf) . "wincmd w"
				silent! hide
			endif
		endfor
		silent exe "silent! ". l:current_tab . "tabnext"
		call s:IDE_RecPreWindowWidth()
		call s:IDE_ToggleOpen()
		call s:IDE_RecWindowWidth()
		" Go back to the original window if IDE_isGainFocusOnToggle is not set
		if !s:IDE_isGainFocusOnToggle
			call s:IDE_ExeWithoutAucmds('wincmd p')
		endif
	else
		call s:IDE_ErrorMsg("Unable to toggle, the IDE buffer has been wipeout")
		return
	endif
endfunction
">>>
" === IDE_ResizeWindow() =================================================<<<
function! s:IDE_ResizeWindow()
	if s:IDE_isToggleSize
		let l:windowWidth = winwidth('.')
		if s:IDE_isToggled == 1
			let s:IDE_isToggled = 0
			let l:windowWidth = s:IDE_userWindowWidth
		else
			let s:IDE_isToggled = 1
			let l:windowWidth += g:IDE_WindowIncrement
		endif
		exe 'silent! vertical resize '.l:windowWidth
	endif
endfunction
">>>
" === IDE_RecPreWindowWidth() ============================================<<<
function! s:IDE_RecPreWindowWidth()
	if s:IDE_isWindowSizeChanged == -1
		" Open a vertically split window. Increase the window size, if
		" needed, to accomodate the new window
		if s:IDE_isResizable && &columns < (80 + s:IDE_userWindowWidth)
			" Save the original window position
			let s:IDE_pre_winx = getwinposx()
			let s:IDE_pre_winy = getwinposy()
			" one extra column is needed to include the vertical split
			let &columns= &columns + s:IDE_userWindowWidth + 1
			let s:IDE_isWindowSizeChanged = 1
		else
			let s:IDE_isWindowSizeChanged = 0
		endif
	endif
endfunction
">>>
" === IDE_RecWindowWidth() ===============================================<<<
function! s:IDE_RecWindowWidth()
	let s:IDE_winx = getwinposx()
	let s:IDE_winy = getwinposy()
endfunction
">>>
" === IDE_RevertWindow() =================================================<<<
function! s:IDE_RevertWindowWidth()
	if s:IDE_AppName != "winmanager"
		if s:IDE_isResizable == 0 || s:IDE_isWindowSizeChanged != 1 || &columns < (80 + s:IDE_userWindowWidth)
			" No need to adjust window width if
			"  * columns is less than 101 or
			"  * user chose not to adjust the window width
		else
			" If the user didn't manually move the window, then restore the window
			" position to the pre-IDE position
			if s:IDE_pre_winx != -1 && s:IDE_pre_winy != -1 &&
						\ getwinposx() == s:IDE_winx &&
						\ getwinposy() == s:IDE_winy
				exe 'winpos ' . s:IDE_pre_winx . ' ' . s:IDE_pre_winy
			endif
			" Adjust the Vim window width
			let &columns= &columns - (s:IDE_userWindowWidth + 1)
		endif
	endif
	let s:IDE_isWindowSizeChanged = -1
endfunction
">>>
" === IDE Syntax
" === IDE_CreateSyntaxTags() =============================================<<<
function! s:IDE_CreateSyntaxTags(verbose)
	if a:verbose
		call s:IDE_InfoMsg("Generating ctags for ".len(s:IDE_File)." file(s) .... writing tags to ".s:IDE_ProjectSyn['tags'])
	endif
	"generate ctags
	let l:tag_cmd = 'ctags -L '.s:IDE_ProjectSyn['files']
	let l:tag_arg = ' --c++-kinds=+p --java-kinds=+p --fields=+aKz --extra= --languages=+c++,java --langmap=c:+.c.x,c++:+.inl.cc,java:+j -f '.s:IDE_ProjectSyn['tags']
	let l:out =	system(l:tag_cmd.l:tag_arg)
	if v:shell_error
		call s:IDE_ErrorMsg('ctag cannot generate file '.s:IDE_ProjectSyn['tags'])
	else
		call s:IDE_InfoMsg('ctags file was generated')
	endif

	"ctags -R --file-scope=no --c++-kinds=+p --fields=+iamnlKS --extra=+q
	"      --languages=c++ --langmap=C++:+.inl -I mkid --include="C C++"
endfunction
">>>
" === IDE_UpdateSyntaxFile() =============================================<<<
function! s:IDE_UpdateSyntaxFile(action)
	if a:action =~ '^cmd!$'
		call s:IDE_CopySyntaxScript();
	endif
	if bufnr('%') == s:IDE_Buffer
		call s:IDE_LoseFocus()
		call s:IDE_UpdateSyntax()
		call s:IDE_GainFocus()
	else
		call s:IDE_UpdateSyntax()
	endif
endfunction
">>>
" === IDE_GenerateSyntaxFile_au() ========================================<<<
function! s:IDE_GenerateSyntaxFile_au()
	call s:IDE_TraceLog('IDE_GenerateSyntaxFile_au()')
	call s:IDE_CreateSyntaxFile(1)
	call s:IDE_ExeWithoutAucmds('silent! autocmd! IDEOnceAutoCmd')
endfunction
">>>
" === IDE_UpdateSyntax_au() ==============================================<<<
function! s:IDE_UpdateSyntax_au()
	if (b:IDE_syntaxVersion < s:IDE_syntaxUpdate || !exists("b:current_syntax") || b:current_syntax != "IDE_".s:IDE_ProjectName)
		let b:IDE_syntaxVersion = s:IDE_syntaxUpdate
		silent! exe 'source '.s:IDE_ProjectSyn['syntax_esc']
	endif
endfunction
">>>
" === IDE_UpdateSyntax() =================================================<<<
function! s:IDE_UpdateSyntax()
	call s:IDE_CreateSyntaxFile(1)
	call s:IDE_InfoMsg("IDE syntax for ide-project ".s:IDE_ProjectName." has been updated.")
	call s:IDE_RefreshSyntax()
endfunction
function! s:IDE_RefreshSyntax()
	if (s:IDE_isSyntaxWorking)
		let l:current_buffer=bufnr("%")
		let l:last_buffer=bufnr("$")
		let l:total=l:last_buffer
		let l:count=0
		" the vim buffer list is most likely smaller than the IDE_BufferMap
		while l:last_buffer > 0
			let l:count += 1
			if bufexists(l:last_buffer) && bufloaded(l:last_buffer)
				let l:bufname = fnamemodify(bufname(l:last_buffer),':p')
				if has_key(s:IDE_BufferMap,l:bufname)
					call s:IDE_InfoMsg("Refreshing syntax highlight in IDE files ".(l:count*100/l:total)."%")
					exe "keepjumps silent buffer!".l:last_buffer
					exe "source ".s:IDE_ProjectSyn['syntax_esc']
				endif
			endif
			let l:last_buffer -= 1
		endwhile
		exe "keepjumps silent buffer!".l:current_buffer
		call s:IDE_InfoMsg("Refreshing syntax highlight completed")
	endif
endfunction
">>>
" === IDE_StartSyntax() ==================================================<<<
function! s:IDE_StartSyntax()
	if s:IDE_isSyntaxCapable == 0
		return
	endif
	let l:project = fnamemodify(s:IDE_Launched['name'],":r")
	let l:projectHead = s:IDE_Launched['dir'].'/'.l:project
	let l:projectHead_esc = escape(l:projectHead,' #%')
	let s:IDE_ProjectSyn['syntax'] = l:projectHead . '.ide.syntax'
	let s:IDE_ProjectSyn['syntax_esc'] = l:projectHead_esc . '.ide.syntax'
	let s:IDE_ProjectSyn['root'] = l:project
	let s:IDE_ProjectSyn['files'] = l:project.'.ide.files'
	let s:IDE_ProjectSyn['tags'] = l:project.'.ide.tags'
	if filereadable(s:IDE_ProjectSyn['syntax'])
		call s:IDE_InfoMsg("Found IDE syntax for ".s:IDE_ProjectName)
		let s:IDE_isSyntaxWorking = 1
	else
		"schedule syntax file generation after showing the IDE screen
		augroup IDEOnceAutoCmd
			autocmd!
			autocmd WinEnter __IDE_Project__ call s:IDE_GenerateSyntaxFile_au()
		augroup end
	endif
endfunction
">>>
" === IDE_RetrieveSyntaxScript() =========================================<<<
function! s:IDE_RetrieveSyntaxScript()
	if s:IDE_isSyntaxCapable == 0
		return 0
	endif
	let l:syntaxScript=findfile(s:IDE_syntaxScript)
	if (l:syntaxScript=='')
		if (s:IDE_existSyntaxScript==1)
			return s:IDE_CopySyntaxScript()
		else
			call s:IDE_LogMsg("Cannot find syntax script: ".s:IDE_syntaxScript)
			return 0
		endif
	endif
	return 1
endfunction
function! s:IDE_CopySyntaxScript()
	call s:IDE_LogMsg("Copying script file: ".s:IDE_syntaxScript)
	exe "silent !".s:IDE_cmdDelFile." ".s:IDE_syntaxScript
	exe "silent !".s:IDE_cmdCopy." ".s:IDE_PluginFolder.s:IDE_syntaxScript." ."
	if v:shell_error
		call s:IDE_LogMsg("Cannot copy syntax script: ".s:IDE_syntaxScript)
		return 0
	endif
	return 1
endfunction
">>>
" === IDE_CreateSyntaxFile() =============================================<<<
function! s:IDE_CreateSyntaxFile(verbose)
	let l:syntaxOn = s:IDE_RetrieveSyntaxScript()
	if (l:syntaxOn==1)
		let l:savedir = escape(getcwd(),' #%')
		silent exe "cd " . s:IDE_Launched['dir_esc']
		call s:IDE_CreateSyntaxFileList(a:verbose)
		call s:IDE_CreateSyntaxTags(a:verbose)
		if a:verbose
			call s:IDE_InfoMsg("Generating syntax file ".s:IDE_ProjectSyn['syntax_esc']." for ".len(s:IDE_File)." files")
		endif
		let l:out =	system("./".s:IDE_syntaxScript." ".s:IDE_ProjectSyn['root'])
		if v:shell_error
			call s:IDE_WarnMsg("Failed to (re)generate advanced syntax highlight file.")
			let s:IDE_isSyntaxWorking = 0
		else
			call s:IDE_InfoMsg("Syntax file has been generated")
			if (s:IDE_isSyntaxWorking == 0)
				call s:IDE_InfoMsg("Restarting advanced syntax highlight")
			endif
			let s:IDE_isSyntaxWorking = 1
		endif
		"syntax files should be loaded in the autocommands
		if s:IDE_Launched['dir_esc'] != l:savedir
			silent exe "cd " . l:savedir
		endif
	else
		call s:IDE_ErrorMsg("Cannot find IDE Syntax for".s:IDE_ProjectName." (Disabling syntax feature)")
		let s:IDE_isSyntaxWorking = 0
	endif
endfunction
">>>
" === IDE_CreateSyntaxFileList() =========================================<<<
function! s:IDE_CreateSyntaxFileList(verbose)
	let stop_dbg_redirection = s:IDE_isDebugging
	let s:IDE_isDebugging = 0
	if a:verbose
		call s:IDE_InfoMsg("Gathering files in ide-project for highligth ... writing to ".s:IDE_ProjectSyn['files'])
	endif
	exe 'redir! >  '.s:IDE_ProjectSyn['files']
	for id in keys(s:IDE_File)
		let l:name = s:IDE_File[id]['name']
		let l:parent_id = s:IDE_File[id]['parent']
		let l:filename = s:IDE_GetFileName(l:name,l:parent_id)
		silent! echo l:filename
	endfor
	redir END
	let s:IDE_isDebugging = stop_dbg_redirection
endfunction
">>>
" === IDE Sign
"=== IDE_GetBufferStatus() ==============================================<<<
"unlest the bufnumber provided is -1, it will never return 0
function! s:IDE_GetBufferStatus(bufnumber)
	let l:signis = 0
	if a:bufnumber != -1
		let l:signis = 1
		let l:ismodified = getbufvar(a:bufnumber, "&modified")
		if l:ismodified
			let l:signis = 2
		endif
		let l:isreadonly = getbufvar(a:bufnumber,"&readonly")
		if l:isreadonly
			let l:signis = 3
		endif
	endif
	return l:signis
endfunction
">>>
"=== IDE_SignRedrawOpen_au() ============================================<<<
function! s:IDE_SignRedrawOpen_au()
	if s:IDE_Buffer == -1 || !exists('s:IDE_File')
		return
	endif
	let l:bufname = escape(substitute(expand("<afile>:p"), '\\', '/', 'g'), ' ')
	let l:bufnmbr=bufnr(l:bufname)
	call s:IDE_TraceLog('IDE_SignRedrawOpen_au ('.l:bufname.')')
	let l:new_signis = s:IDE_GetBufferStatus(l:bufnmbr)
	if has_key(s:IDE_BufferMap,l:bufname)
		let l:id = s:IDE_BufferMap[l:bufname]
		let l:old_signis = s:IDE_File[l:id]['status']
		if (l:old_signis != new_signis)
			let l:status = s:IDE_GetWindowState(g:IDE_Title)
			if (l:status == 1 || l:status == 2)
				if (l:old_signis == 0)
					call s:IDE_PlaceSign(l:id,l:new_signis)
				else
					call s:IDE_UpdateSign(l:id,l:new_signis)
				endif
				let s:IDE_File[l:id]['status'] = l:new_signis
			elseif (l:status == 3)
				let s:IDE_PendingUpdate[l:id] = {'status':l:new_signis,'name':s:IDE_File[l:id]['name']}
			else
				call s:IDE_ErrorMsg('Attempting to update when the IDE is closed!')
			endif
		endif
	endif
endfunction
">>>
"=== IDE_SignRedrawClose_au() ===========================================<<<
function! s:IDE_SignRedrawClose_au()
	if s:IDE_Buffer != -1 && exists('s:IDE_BufferMap')
		let l:bufname = escape(substitute(expand("<afile>:p"), '\\', '/', 'g'), ' ')
		let l:bufnmbr = bufnr(l:bufname)
		let l:new_signis = 4
		call s:IDE_TraceLog('SignRedrawClose_au '.l:bufname)
		if has_key(s:IDE_BufferMap,l:bufname)
			let l:id = s:IDE_BufferMap[l:bufname]
			let l:old_signis = s:IDE_File[l:id]['status']
			if (l:old_signis != 0) && (l:old_signis != l:new_signis)
				let l:status = s:IDE_GetWindowState(g:IDE_Title)
				if (l:status == 1 || l:status == 2)
					call s:IDE_UpdateSign(l:id,l:new_signis)
					let s:IDE_File[l:id]['status'] = l:new_signis
				elseif (l:status == 3)
					let s:IDE_PendingUpdate[l:id] = {'status':l:new_signis,'name':s:IDE_File[l:id]['name']}
				else
					call s:IDE_ErrorMsg('Attempting to update when the IDE is closed!')
				endif
			endif
		endif
	endif
endfunction
">>>
"=== IDE_SignRemove_au() ================================================<<<
function! s:IDE_SignRemove_au()
	if s:IDE_Buffer == -1 || !exists('s:IDE_File')
		return
	endif
	let l:bufname = escape(substitute(expand("<afile>:p"), '\\', '/', 'g'), ' ')
	call s:IDE_TraceLog('SignRemove_au '.l:bufname)
	"echo 'redrawing close'
	if has_key(s:IDE_BufferMap,l:bufname)
		let l:id = s:IDE_BufferMap[l:bufname]
		let l:old_signis = s:IDE_File[l:id]['status']
		if l:old_signis != 0
			let l:status = s:IDE_GetWindowState(g:IDE_Title)
			if (l:status == 1 || l:status == 2)
				call s:IDE_RemoveSign(l:id)
				let s:IDE_File[l:id]['status'] = 0
			elseif (l:status == 3)
				let s:IDE_PendingUpdate[l:id] = {'status':0,'name':s:IDE_File[l:id]['name']}
			else
				call s:IDE_ErrorMsg('Attempting to update when the IDE is closed!')
			endif
		endif
	endif
endfunction
">>>
"=== IDE_PendingUpdate_au() =============================================<<<
function! s:IDE_PendingUpdate_au()
	for id in keys(s:IDE_PendingUpdate)
		if s:IDE_File[id]['name'] == s:IDE_PendingUpdate[id]['name']
			"if the IDE_File gets updated (user modification) use the
			"name as a fail check to avoid updating the incorrect sign line
			let l:oldsign = s:IDE_File[id]['status']
			let l:newsign = s:IDE_PendingUpdate[id]['status']
			if (l:newsign != l:oldsign)
				if (l:newsign == 0)
					call s:IDE_RemoveSign(id)
				else
					if (l:oldsign == 0)
						call s:IDE_PlaceSign(id,l:newsign)
					else
						call s:IDE_UpdateSign(id,l:newsign)
					endif
				endif
				let s:IDE_File[id]['status'] = l:newsign
			endif
			"else
			" IDE_File has been modified
			" todo:
			" we can recover the sign by doing a traversal of the files
			" but it might be expensive and running time will vary depending
			" on the new location.
		endif
		unlet s:IDE_PendingUpdate[id]
	endfor
endfunction
">>>
" === IDE_UpdateSign() ===================================================<<<
" === no need to be in focus, sign takes as argument the IDE buffer
function! s:IDE_UpdateSign(id,signis)
	if s:IDE_isEnableSignMarks
		try
			silent exe 'sign place '.a:id.' name=IDEsign'.a:signis.' buffer='.s:IDE_Buffer
		catch /.*/
			call s:IDE_ErrorMsg("Exception caught while updating sing mark ".v:throwpoint)
		endtry
	endif
endfunction
">>>
" === IDE_PlaceSign() ====================================================<<<
" === no need to be in focus, sign takes as argument the IDE buffer
function! s:IDE_PlaceSign(id,signis)
	if s:IDE_isEnableSignMarks
		let l:atline = s:IDE_GetLocation(a:id)
		try
			silent exe 'sign place '.a:id.' name=IDEsign'.a:signis.' line='.l:atline.' buffer='.s:IDE_Buffer
		catch /.*/
			call s:IDE_ErrorMsg("Exception caught while placing sign mark ".v:throwpoint)
		endtry
	endif
endfunction
">>>
" === IDE_RemoveSign() ===================================================<<<
" === no need to be in focus, sign takes as argument the IDE buffer
function! s:IDE_RemoveSign(id)
	if s:IDE_isEnableSignMarks
		try
			silent exe 'sign unplace '.a:id.' buffer='.s:IDE_Buffer
		catch /.*/
			call s:IDE_ErrorMsg('Exception caught while removing sign mark '.v:throwpoint)
		endtry
	endif
endfunction
">>>
" === IDE_RemoveAllSign_au() =============================================<<<
" === Assumes we are in focus, in IDE buffer
function! s:IDE_RemoveAllSign_au()
	if s:IDE_Buffer != -1 && exists('s:IDE_BufferMap')
		for key in keys(s:IDE_BufferMap)
			let l:id = s:IDE_BufferMap[key]
			if s:IDE_File[l:id]['status'] != 0
				call s:IDE_RemoveSign(l:id)
				let s:IDE_File[l:id]['status'] = 0
			endif
		endfor
	endif
endfunction
">>>
" === IDE_ForceRemoveAllSign() ===========================================<<<
" === Assumes we are in focus, in IDE buffer
function! s:IDE_ForceRemoveAllSign()
	if s:IDE_Buffer != -1 && exists('s:IDE_BufferMap')
		for key in keys(s:IDE_BufferMap)
			let l:id = s:IDE_BufferMap[key]
			if s:IDE_File[l:id]['status'] != 0 && !has_key(s:IDE_PendingUpdate,l:id)
				call s:IDE_RemoveSign(l:id)
				" If a new file was created or deleted the table
				" s:IDE_PendingUpdate[key]['atline'] will be wrong.
				let s:IDE_PendingUpdate[l:id] = {'status':s:IDE_File[l:id]['status'],'name':s:IDE_File[l:id]['name']}
			endif
		endfor
	endif
endfunction
">>>
" === IDE_ForceRedrawAllSign() ===========================================<<<
" === Assumes we are in focus, in IDE buffer, table s:IDE_BufferMap has been updated
function! s:IDE_ForceRedrawAllSign()
	call s:IDE_TraceLog('IDE_ForceRedrawAllSing()')
	call s:IDE_Assert(s:IDE_GetWindowState(g:IDE_Title)==1,"Not in the IDE buffer")
	if s:IDE_Buffer != -1 && exists('s:IDE_PendingUpdate') && exists('s:IDE_BufferMap')
		"syncronize s:IDE_PendingUpdate[id][atline] with s:IDE_BufferMap[id][atline]
		"syncronize s:IDE_BufferMap[id][status] with s:IDE_PendingUpdate[id][status]
		for id in keys(s:IDE_PendingUpdate)
			" cannot trust IDE_PendingUpdate ids given by ids,
			" its ids could have been invalidated
			if has_key(s:IDE_File,id) && s:IDE_File[id]['name'] == s:IDE_PendingUpdate[id]['name']
				"cannot even trust the s:IDE_File because:
				" - it might have been reconstructed from dir (removing old files)
				" - it might have moved comment lines
				" - projects might have shift entirely so they seat on an old file location
				let l:name = s:IDE_File[id]['name']
				let l:parent_id = s:IDE_File[id]['parent']
				let l:filename = s:IDE_GetFileName(l:name,l:parent_id)
				let l:bufnmbr = bufnr(l:filename)
				if has_key(s:IDE_BufferMap,l:filename) && (l:bufnmbr!=-1)
					let l:id = s:IDE_BufferMap[l:filename]
					let l:signis = s:IDE_PendingUpdate[id]['status']
					let s:IDE_File[l:id]['status'] = l:signis
					call s:IDE_PlaceSign(l:id,l:signis)
				endif
				"else
				" this sign will be recovered after jumping to the file in question
				"call s:IDE_LogMsg("Pending sign status for id ".id." was lost")
			endif
			unlet s:IDE_PendingUpdate[id]
		endfor
	endif
endfunction
">>>
"
"================ Project Management =================================================
"
" === New and/or re-wrote functions
" === IDE_AddEntry() =====================================================<<<
function! s:IDE_AddEntry(line)
	let l:line = a:line
	let l:id = s:IDE_GetID(l:line)
	if l:id < s:IDE_ProjectID || l:id > s:IDE_ProjectEND || foldlevel(l:line) == 0
		s:IDE_InfoMsg("Cannot add a file outside the ide-project")
		return
	endif
	let l:parent = s:IDE_GetThisProjectBegin(l:line)
	let l:home = s:IDE_Project[l:parent]['home']
	let l:proj = s:IDE_Project[l:parent]['name']
	echohl MoreMsg
	let l:name = input("IDE: Enter the file name (absolute or relative) to be added to ide-project ".l:proj." > ")
	echohl None
	if strlen(l:name) == 0
		return
	endif
	let l:foldlev=foldlevel(l:line)
	if (foldclosed(l:line) != -1) || (getline(l:line) =~ '}')
		let l:foldlev=l:foldlev - 1
	endif
	call s:IDE_BeforeEdit()
	call append(l:line,l:name)
	call s:IDE_AfterEdit()
endfunction
">>>
" === IDE_RemoveEntry() ==================================================<<<
function! s:IDE_RemoveEntry(line)
	let l:line = a:line
	if foldlevel(l:line) == 0
		return
	endif
	let l:id = s:IDE_GetID(l:line)
	if l:id < s:IDE_ProjectID || l:id >= s:IDE_ProjectEND
		return
	endif
	let l:delete = 0
	if has_key(s:IDE_Project,l:id)
		if foldclosed(l:line) != -1
			" delete the entire project and its sub projects
			let l:delete = 1
		else
			call s:IDE_InfoMsg("To delete an ide-project and its subprojects close it first")
		endif
	elseif has_key(s:IDE_File,l:id)
		" delete a file
		let l:delete = 1
	elseif (foldclosed(l:line) != -1) || (getline(l:line) =~ '}')
		call s:IDE_InfoMsg("To merge project-files edit the ide with [i]")
	else
		" delete a comment or blank line
		let l:delete = 1
	endif
	if l:delete
		call s:IDE_BeforeEdit()
		exe "silent! normal! dd"
		call s:IDE_AfterEdit()
	endif
endfunction
">>>
" === IDE_Modify() =======================================================<<<
function! s:IDE_Modify(line)
	let l:line = a:line
	let l:foldlev=foldlevel(l:line)
	if (foldclosed(l:line) != -1) || (getline(l:line) =~ '}')
		let l:foldlev=l:foldlev - 1
	endif
	setlocal modifiable
endfunction
">>>
" === IDE_ConstructProject(at_line,parent_id) ============================<<<
" === Construct the data structure of the project ONCE
" assume lineno is the start of a project (TOP at the beginning)
function! s:IDE_ConstructProject(at_line,parent)
	call s:IDE_TraceLog('IDE_ConstructProject('.a:at_line.','.a:parent.')')
	let l:at_line=a:at_line
	let l:baseline=a:at_line
	let l:infoline = getline(l:at_line)
	while l:infoline =~ '^\s*#'
		let l:at_line = l:at_line+1
		let l:infoline = getline(l:at_line)
	endwhile
	" Extract parent information if any
	let l:parent_home = ''
	let l:parent_cd=''
	let l:parent_filter=''
	let l:parent_flags=''
	let l:parent_in=''
	let l:parent_out=''
	let l:id = s:IDE_GetID(l:baseline)
	let l:parent_id=''
	if a:parent!=''
		let l:parent_id = s:IDE_GetID(a:parent)
		if has_key(s:IDE_Project,l:parent_id)
			let l:parent_home = s:IDE_Project[l:parent_id]['home']
			let l:parent_cd = s:IDE_Project[l:parent_id]['cd']
			let l:parent_filter = s:IDE_Project[l:parent_id]['filter']
			let l:parent_flags = s:IDE_Project[l:parent_id]['flags']
			let l:parent_in = s:IDE_Project[l:parent_id]['in']
			let l:parent_out = s:IDE_Project[l:parent_id]['out']
		else
			call s:IDE_ErrorMsg("Parent ID=".l:parent_id." not found on constructed projects")
		endif
	else
		let s:IDE_ProjectID = l:id
	endif
	let l:name=s:IDE_GetProjectName(l:infoline,l:at_line)
	" Extract the home directory of the project
	" (guarantee to be absolute path)
	let l:home=s:GetHome(l:infoline,l:parent_home)
	if !isdirectory(l:home)
		call s:IDE_ErrorMsg('Path of ide-project '.l:name.'('.l:home.') does not exist')
	endif
	" Extract any CD information
	let l:c_d = s:GetCd(l:infoline, l:home)
	if l:c_d != ''
		if !s:IsAbsolutePath(l:c_d) || !isdirectory(glob(l:c_d))
			call s:IDE_ErrorMsg('CD of ide-project '.l:name.'('.l:c_d.') must have absolute path and be a valid directory!')
			let l:c_d = '.'  " Some 'reasonable' value
		endif
	else
		let l:c_d = l:parent_cd
	endif
	" Extract scriptin
	let l:scriptin = s:GetScriptin(l:infoline, l:home)
	if l:scriptin == ''
		let l:scriptin = l:parent_in
	endif
	" Extract scriptout
	let l:scriptout = s:GetScriptout(l:infoline, l:home)
	if l:scriptout == ''
		let l:scriptout = l:parent_out
	endif
	" Extract filter
	let l:filter = s:GetFilter(l:infoline,'')
	if l:filter == ''
		let l:filter = l:parent_filter
	endif
	" Extract flags
	let l:flags = s:GetFlags(l:infoline)
	if l:flags == ''
		let l:flags = l:parent_flags
	endif
	let l:last_line = line("$")
	let l:project={'name':l:name,'home':l:home,'cd':l:c_d,'in':l:scriptin,'out':l:scriptout,'filter':l:filter,'flags':l:flags,'parent':l:parent_id,'end':l:last_line}
	let s:IDE_Project[l:id]=l:project
	let l:foldlev=foldlevel(l:at_line)
	let l:properEnd = 0
	if l:foldlev >= 1
		while l:at_line < line('$')
			let l:at_line = l:at_line + 1
			let l:at_id = s:IDE_GetID(l:at_line)
			let l:line=getline(l:at_line)
			" skip comment and blank lines
			if l:line =~ '^\s*#' || l:line == ''
				continue
			endif
			" get ride of trailing white space and comments
			let l:linw=substitute(l:line, '\s*#.*', '', '')
			" get ride of initial white space
			let l:line = substitute(l:line,'^\s*\(.*\)','\1','')
			if l:line =~ '}'
				"end of a (sub)project
				let l:properEnd = 1
				break
			elseif l:line =~ '{'
				"start of a subproject
				"branch till one pass its end
				let l:at_line = s:IDE_ConstructProject(l:at_line,l:baseline)
			else
				let l:filename=l:line
				let l:filedata={'name':l:filename,'parent':l:id,'status':0}
				let s:IDE_File[l:at_id]=l:filedata
				"call s:IDE_InfoMsg('traversing file='.l:line.' from base='.s:IDE_Project[l:id]['home'])
				if !s:IsAbsolutePath(l:filename)
					let l:filename=l:home.'/'.l:filename
				endif
				let l:filename = s:IDE_GetConsistentFileName(l:filename)
				let s:IDE_BufferMap[l:filename]=l:at_id
			endif
		endwhile
		if l:properEnd == 0
			call s:IDE_ErrorMsg('End of project-file '.l:name.' reached without closing brackets, check your syntax')
		endif
	endif
	return l:at_line
endfunction
">>>
" === IDE_ConstructProjectData() =========================================<<<
function! s:IDE_ConstructProjectData()
	" this is the natural place to update the syntax threshold
	let l:file_count = len(keys(s:IDE_File))
	let l:syntax_threshold = substitute(g:IDE_UpdateSyntaxAt,'%.*','','g')
	if match(g:IDE_UpdateSyntaxAt,'\C%') != -1
		let s:IDE_syntaxThreshold = l:file_count*l:syntax_threshold/100
	endif
	" finish putting the boundaries of the projects
	for id in keys(s:IDE_Project)
		let l:eof = s:IDE_GetProjectsEOF(id)
		let s:IDE_Project[id]['end'] = l:eof
		let l:line = s:IDE_GetLocation(l:id)
		if foldlevel(l:line)>s:IDE_MaxDepth
			let s:IDE_MaxDepth = foldlevel(l:line)
		endif
	endfor
endfunction
">>>
" === IDE_GetFileName(file,parent_line) ==================================<<<
" assumes file & parent_line come from IDE_File
function! s:IDE_GetFileName(filename,parent_line)
	let l:filename = a:filename
	if !s:IsAbsolutePath(l:filename)
		let l:path=s:IDE_Project[a:parent_line]['home']
		let l:filename=l:path.'/'.l:filename
		let l:filename=s:IDE_GetConsistentFileName(l:filename)
	endif
	return l:filename
endfunction
">>>
" === IDE_OpenFileEntry(id,edit_cmd) =====================================<<<
function! s:IDE_OpenFileEntry(id,editcmd)
	call s:IDE_TraceLog('s:IDE_OpenFileEntry('.a:id.','.a:editcmd.')')
	if !has_key(s:IDE_File,a:id)
		return 0
	endif
	let l:filename=s:IDE_File[a:id]['name']
	let l:parent=s:IDE_File[a:id]['parent']
	let l:filename = s:IDE_GetFileName(l:filename,l:parent)
	let l:reopenTab = 0
	if !s:IDE_isLastBufferInWindow()
		call s:IDE_ToggleClose()
		let l:reopenTab = 1
	endif
	let l:needSetup = s:IDE_OpenOrJumpTo(l:filename,a:editcmd)
	if l:needSetup || !exists('b:IDE_autocmd_ID')
		call s:IDE_SetupFile(l:parent)
		call s:IDE_SetupFileAutocommand(l:filename)
	endif
	if l:reopenTab
		call s:IDE_ToggleOpen()
		call s:DoWindowSetupAndSplit()
	endif
	return 1
endfunction
">>>
" === IDE_OpenOrJumpTo(filename,edit_cmd) ================================<<<
" === not in focus unleast we're the last window
function! s:IDE_OpenOrJumpTo(fname, editcmd)
	call s:IDE_TraceLog('IDE_OpenOrJumpTo('.a:fname.','.a:editcmd.')')
	let l:fname = a:fname
	let _bufNbr = bufnr(l:fname)
	if bufexists(_bufNbr)
		"if bufnr("#") == _bufNbr
		"	call s:IDE_InfoMsg("File ".l:fname." on buffer "._bufNbr." is an alternate buffer")
		"endif
		exe "keepjumps silent buffer!".bufnr("%")
		let tabNbr = s:IDE_GetTabNbr(_bufNbr)
		if tabNbr == 0
			" _bufNbr is not opened in any tabs
			silent exe "silent! 999tab split +buffer" . _bufNbr
		else
			" _bufNbr is already opened in tab(s)
			silent exe "silent! ". tabNbr . "tabnext"
			" Focus window.
			silent exe "silent! " . s:GetWinNbr(tabNbr, _bufNbr) . "wincmd w"
		endif
		" Make the buffer 'listed' again.
		call setbufvar(_bufNbr, "&buflisted", "1")
		return 0
	else
		let edit_cmd = a:editcmd
		let current_win = winnr()
		if current_win != bufwinnr(s:IDE_Buffer)
			" defenetively out of focus
			let current_buf = winbufnr(current_win)
			let current_mod = getbufvar(current_buf,'&modified')
			let current_name = bufname(current_buf)
			" if the current buffer is unuse, grab it
			if (current_mod != 1) && (current_name == '')
				let edit_cmd = "edit"
			endif
		endif
		let l:fname=escape(l:fname,' ')
		silent exe 'silent! '.edit_cmd.'! '.l:fname
		" we should be at the newly created buffer
		" and the buffer should match our prediction
		let l:bufname=escape(substitute(expand('%:p', 0), '\\', '/', 'g'),' ')
		call s:IDE_Assert(l:fname==l:bufname,"Buffer mismatch!. Got buffer(".l:bufname.") Expected(".l:fname.")")
		return 1
	endif
endfunction
">>>
" === IDE_SetupFile(buffer_number) =======================================<<<
" === not in focus unleast we're the last window
function! s:IDE_SetupFile(project)
	let l:parent = a:project
	" Extract any CD information
	let l:c_d = s:IDE_Project[l:parent]['cd']
	let l:home = s:IDE_Project[l:parent]['home']
	if l:c_d != '' && (s:IsAbsolutePath(l:home) != 2)
		if s:IDE_isChangingCWD
			call s:SetupAutoCommand(l:c_d)
		endif
		if !isdirectory(glob(l:c_d))
			call s:IDE_ErrorMsg('ide-project '.s:IDE_Project[l:parent]['name'].' CD='.'"'.l:c_d.'" is not a valid directory.')
		else
			silent exe s:IDE_cmdCd .' '.l:c_d
		endif
	endif
	" Extract any scriptin information
	let scriptin = s:IDE_Project[l:parent]['in']
	if scriptin != ''
		if !filereadable(glob(scriptin))
			call s:IDE_ErrorMsg('ide-Project '.s:IDE_Project[l:parent]['name'].' script in="'.scriptin.'" cannot be not found. Ignoring.')
		else
			call s:SetupScriptAutoCommand('BufEnter', scriptin)
			exe 'source '.scriptin
		endif
	endif
	" Extract any scriptout information
	let scriptout =  s:IDE_Project[l:parent]['out']
	if scriptout != ''
		if !filereadable(glob(scriptout))
			call s:IDE_ErrorMsg('ide-Project '.s:IDE_Project[l:parent]['name'].' script out="'.scriptin.'" cannot be not found. Ignoring.')
		else
			call s:SetupScriptAutoCommand('BufLeave', scriptout)
		endif
	endif
endfunction
">>>
" === IDE_SetupFileAutocommand(buffer) ===================================<<<
function! s:IDE_SetupFileAutocommand(buffer)
	call s:IDE_Assert(s:IDE_GetConsistentFileName('%:p') == a:buffer,"Not in the file buffer ".a:buffer)
	if  !filereadable(s:IDE_ProjectSyn['syntax'])
		call s:IDE_ErrorMsg("Disabling advanced syntax highlight. Cannot find syntax file (".s:IDE_ProjectSyn['syntax'].')')
		let s:IDE_isSyntaxWorking = 0
	endif
	if s:IDE_isSyntaxWorking
		silent! exe 'source '.s:IDE_ProjectSyn['syntax_esc']
	endif
	exe 'nnoremap <buffer> <silent> ' . g:IDE_FetchInProjectRecursive	. ' :call <SID>IDE_SearchForWord(0)<CR>'
	exe 'nnoremap <buffer> <silent> ' . g:IDE_FetchInAllProjects		. ' :call <SID>IDE_SearchForWord(1)()<CR>'
	let s:IDE_autocmdID += 1
	let b:IDE_autocmd_ID = "IDE_FileAutoCommands_".s:IDE_autocmdID
	let b:IDE_syntaxVersion = s:IDE_syntaxUpdate
	let l:old_cpoptions = &cpoptions
	set cpoptions&vim
	exe 'augroup '.b:IDE_autocmd_ID
	silent! exe 'autocmd! '.b:IDE_autocmd_ID
	autocmd SwapExists <buffer> call s:IDE_HandleSwapFile_au()
	autocmd BufUnload,BufWipeout <buffer>  call s:IDE_FileHasBeenClosed_au()
	if s:IDE_isSyntaxWorking
		if (s:IDE_syntaxThreshold>0)
			autocmd BufWritePost <buffer> call s:IDE_TrackProjectChanges_au()
		endif
		autocmd BufRead,BufNewFile <buffer> silent! exe source s:IDE_ProjectSyn['syntax_esc']
		"autocmd CursorHold <buffer> call s:IDE_UpdateSyntax_au()
		autocmd BufEnter <buffer> call s:IDE_UpdateSyntax_au()
	endif
	if s:IDE_isEnableSignMarks
		autocmd BufEnter,BufLeave <buffer> call s:IDE_SignRedrawOpen_au()
		if s:IDE_isEnableSignMarksClose
			autocmd BufUnload,BufWipeout <buffer> call s:IDE_SignRedrawClose_au()
		else
			autocmd BufUnload,BufWipeout <buffer> call s:IDE_SignRemove_au()
		endif
	endif
	exe 'augroup end'
	" Restore the previous cpoptions settings
	let &cpoptions = l:old_cpoptions
endfunction
">>>
" === IDE_ShowInfo(at_line) ==============================================<<<
function! s:IDE_ShowInfo_atline()
	call s:IDE_ShowInfo(line('.'))
endfunction
function! s:IDE_ShowInfo(at_line)
	let l:id = s:IDE_GetID(a:at_line)
	if exists('s:IDE_Project') && has_key(s:IDE_Project,l:id)
		let l:name = s:IDE_Project[l:id]['name']
		let l:path = s:IDE_Project[l:id]['home']
		call s:IDE_InfoMsg('Project '.l:name.' (path='.l:path.')')
	elseif exists('s:IDE_File') && has_key(s:IDE_File,l:id)
		let l:name = s:IDE_File[l:id]['name']
		let l:parent = s:IDE_File[l:id]['parent']
		let l:filename=s:IDE_GetFileName(l:name,l:parent)
		let l:prj = s:IDE_Project[l:parent]['name']
		let l:ok = "(file exist)"
		if !filereadable(l:filename)
			let l:ok = "(file not found)"
		endif
		call s:IDE_InfoMsg('File '.l:filename.' '.l:ok)
		"else
		"	call s:IDE_InfoMsg('comment or decorative line')
	endif
endfunction
">>>
" === IDE_ShowInfoDetailed(line) =========================================<<<
function! s:IDE_ShowInfoDetailed_atline()
	call s:IDE_ShowInfoDetailed(line('.'))
endfunction
function! s:IDE_ShowInfoDetailed(at_line)
	let l:id = s:IDE_GetID(a:at_line)
	if exists('s:IDE_Project') && has_key(s:IDE_Project,l:id)
		let l:info = 'Project ' . s:IDE_Project[l:id]['name']
		if s:IDE_Project[l:id]['parent'] == ''
			let l:info = 'Main project '.s:IDE_Project[l:id]['name']
		else
			let l:ide = l:id
			let l:info = ''
			while l:ide != ''
				let l:info = '::'.s:IDE_Project[l:ide]['name'] . l:info
				let l:ide = s:IDE_Project[l:ide]['parent']
			endwhile
		endif
		let l:info .= ' (path=' .s:IDE_Project[l:id]['home'].')'
		let l:eof = s:IDE_Project[l:id]['end']
		let l:ownfiles = 0
		let l:allfiles = 0
		let l:subproj = 0
		let l:iter = l:id + 1
		while l:iter < l:eof
			if has_key(s:IDE_Project,l:iter)
				let l:subproj += 1
			elseif has_key(s:IDE_File,l:iter)
				let l:allfiles += 1
				if s:IDE_File[l:iter]['parent'] == l:id
					let l:ownfiles += 1
				endif
			endif
			let l:iter += 1
		endwhile
		if l:subproj > 0
			let l:info .= ' owns '.l:ownfiles.' out of '.l:allfiles.' files, in '.l:subproj.' sub projects'
		else
			let l:info .= ' owns '.l:ownfiles.' file(s)'
		endif
	elseif exists('s:IDE_File') && has_key(s:IDE_File,l:id)
		let l:name = s:IDE_File[l:id]['name']
		let l:parent = s:IDE_File[l:id]['parent']
		let l:filename=s:IDE_GetFileName(l:name,l:parent)
		let l:info = 'File '.l:filename.' belongs to project '. s:IDE_Project[l:parent]['name']
		if filereadable(l:filename)
			let l:info .= " (file exist)"
		else
			let l:info .= " (file not found)"
		endif
	else
		let l:info = 'help, end of fold or comment'
	endif
	call s:IDE_InfoMsg(l:info)
endfunction
">>>
" === IDE_GetThisProjectBegin(id) ========================================<<<
" Assumes we're in the IDE  buffer
function! s:IDE_GetThisProjectBegin(id)
	call s:IDE_Assert(s:IDE_GetWindowState(g:IDE_Title) == 1, "Not in the IDE buffer")
	let l:id = a:id
	let l:lineno = s:IDE_GetLocation(l:id)
	while l:id >= s:IDE_ProjectID && foldlevel(l:lineno) >= 1
		if has_key(s:IDE_Project,l:id)
			return l:id
		elseif has_key(s:IDE_File,l:id)
			return s:IDE_File[l:id]['parent']
		endif
		let l:lineno -= 1
		let l:id -= 1
	endwhile
	call s:IDE_ErrorMsg("runoff at the beginning of the ide-project")
	return s:IDE_ProjectEND
endfunction
">>>
" === IDE_GetThisProjectEnd(id)      =====================================<<<
function! s:IDE_GetThisProjectEnd(id)
	let l:id = s:IDE_GetThisProjectBegin(a:id)
	return s:IDE_Project[l:id]['end']
endfunction
">>>
" === IDE_GetProjectsEOF(id) =============================================<<<
function! s:IDE_GetProjectsEOF(id)
	"echomsg "entering with id=".a:id."\n"
	let l:id = a:id
	let l:lineno = s:IDE_GetLocation(l:id)
	let l:owner = s:IDE_GetThisProjectBegin(l:id)
	if l:owner == s:IDE_ProjectID
		" if it is the main project
		" we already know where it ends
		return s:IDE_ProjectEND
	endif
	if (l:id == l:owner)
		" if we are at the beginning of a project
		" move forward once to start traversing
		let l:id += 1
		let l:lineno += 1
	endif
	let l:stop = s:IDE_Project[l:owner]['parent']
	let l:level = foldlevel(s:IDE_GetLocation(l:owner))
	while l:id < s:IDE_ProjectEND && foldlevel(l:lineno) >= l:level
		if has_key(s:IDE_Project,l:id)
			if s:IDE_Project[l:id]['parent'] == l:stop
				return l:id - 1
			else
				let l:id = s:IDE_GetProjectsEOF(l:id)
				let l:lineno = s:IDE_GetLocation(l:id)
			endif
		endif
		let l:lineno += 1
		let l:id += 1
	endwhile
	" we've surpassed the fold level of the current project
	" without reaching a next project, we might be in a deep
	" nester project
	let l:id -= 1
	return l:id
	"call s:IDE_WarnMsg("runoff at the end of the project")
	"return s:IDE_ProjectEND
endfunction
">>>
" === IDE_ForEachFileInProject(recurse,line,cmd,data,match) ==============<<<
" Assumes we are in the IDE buffer
function! s:IDE_ForEachFileInProject(recurse, id, cmd, data, match)
	call s:IDE_TraceLog('IDE_ForEachFileInProject('.a:recurse.','.a:id.','.a:cmd.','.a:data.','.a:match.')')
	call s:IDE_Assert(s:IDE_GetWindowState(g:IDE_Title) == 1, "Not in the IDE buffer")
	let l:id = a:id
	let l:base = s:IDE_GetThisProjectBegin(l:id)
	if (l:base == s:IDE_ProjectEND)
		return
	endif
	let l:id = l:base + 1
	let l:flags = s:IDE_Project[l:base]['flags']
	if (l:flags == '') || (a:match=='') || (match(l:flags, a:match) != -1)
		call s:IDE_ForEachFileInProjectRecursively(a:recurse, l:base, l:id, a:cmd, a:data, a:match)
	endif
endfunction
">>>
" === IDE_ForEachFileInProjectRecursively(rec,parent,line,cmd,data,mat) ==<<<
function! s:IDE_ForEachFileInProjectRecursively(recurse, parent_id, id, cmd, data, match)
	call s:IDE_TraceLog('IDE_ForEachFileInProjectRecursively('.a:recurse.','.a:parent_id.','.a:id.','.a:cmd.','.a:data.','.a:match.')')
	let l:stop = s:IDE_GetThisProjectEnd(a:parent_id)
	let l:id = a:id
	while l:id < l:stop
		if exists("b:stop_everything") && b:stop_everything
			return 0
		endif
		if has_key(s:IDE_Project,l:id)
			if a:recurse
				let l:flags=s:IDE_Project[l:id]['flags']
				if (l:flags == '') || (a:match=='') || (match(l:flags, a:match) != -1)
					let l:id=s:IDE_ForEachFileInProjectRecursively(1, l:id, l:id+1, a:cmd, a:data, a:match)
				else
					let l:id=s:IDE_GetThisProjectEnd(l:id)
				endif
			else
				let l:id=s:IDE_GetThisProjectEnd(l:id)
			endif
		elseif has_key(s:IDE_File,l:id)
			if a:cmd[0] == '*'
				call {strpart(a:cmd, 1)}(l:id,a:data,)
			else
				call {a:cmd}(l:id,a:data)
			endif
			"else: skip comment and blank lines
		endif
		let l:id=l:id + 1
	endwhile
	return l:id
endfunction
">>>
" === IDE_LoadAllFilesInProject(recurse,atline) ==========================<<<
function! s:IDE_LoadAllFilesInProject_atline(recurse)
	call s:IDE_LoadAllFilesInProject(a:recurse,line('.'))
endfunction
function! s:IDE_LoadAllFilesInProject(recurse,at_line)
	let b:loadcount=0
	function! s:SpawnExec(id,data)
		let id=a:id
		if s:IDE_OpenFileEntry(id,g:IDE_DefaultOpenMethod)
			wincmd p
			let b:loadcount=b:loadcount+1
			if getchar(0) != 0
				let b:stop_everything=1
			endif
		endif
	endfunction
	let l:id = s:IDE_GetID(a:at_line)
	call s:IDE_ForEachFileInProject(a:recurse, l:id, "<SID>SpawnExec", 0, '^\(.*l\)\@!')
	delfunction s:SpawnExec
	call s:IDE_InfoMsg(b:loadcount." Files Loaded")
	unlet b:loadcount
	if exists("b:stop_everything")
		unlet b:stop_everything
	endif
endfunction
">>>
" === IDE_GetTabNbr(buf_nbr) =============================================<<<
" === Get the tab number of the existing bufer
function! s:IDE_GetTabNbr(bufNbr)
	" Searching buffer bufno, in tabs.
	for i in range(tabpagenr("$"))
		if index(tabpagebuflist(i + 1), a:bufNbr) != -1
			return i + 1
		endif
	endfor
	return 0
endfunction
">>>
" === IDE_GetWinNbr(tab_number,buf_number) ===============================<<<
function! s:GetWinNbr(tabNbr, bufNbr)
	" window number in tabpage.
	return index(tabpagebuflist(a:tabNbr), a:bufNbr) + 1
endfunction
">>>
" === IDE_RefreshEntriesFrom() ===========================================<<<
function! s:IDE_RefreshEntriesFrom(recursive,type)
	"                 0           1
	"a:recursive     off          on
	"a:type        from ide    from dir
	call s:IDE_BeforeEdit()
	call s:IDE_RefreshEntries(a:recursive,a:type)
	call s:IDE_AfterEdit()
endfunction
">>>
" === IDE_RefreshEntries(recurse) ========================================<<<
function! s:IDE_RefreshEntries(recursive,type)
	if foldlevel('.') == 0
		call s:IDE_InfoMsg('Nothing to refresh.')
		return
	endif
	call s:IDE_TraceLog("IDE_RefreshEntriesStart(".a:recursive.")")
	let l:id = s:IDE_GetThisProjectBegin(line('.'))
	if (a:recursive)
		"walk backwards the project structure
		let l:iter = s:IDE_Project[l:id]['end']
	else
		let l:iter = l:id
	endif
	let l:torefresh = {}
	let l:idlist = []
	while l:iter >= l:id
		exe l:iter
		if has_key(s:IDE_Project,l:iter)
			let l:flags = s:IDE_Project[l:iter]['flags']
			let l:atTop = s:IDE_isSubProjectToTop
			let l:sort = s:IDE_isSortingOn
			let l:refresh = 1
			if l:flags != ''
				if match(l:flags, '\Cr') != -1
					" refresh is off for this (sub)project
					"let l:refresh = 0
				endif
				if match(l:flags, '\CT') != -1
					let l:atTop = 1
				endif
				if match(l:flags, '\Ct') != -1
					let l:atTop = 0
				endif
				if match(l:flags, '\CS') != -1
					let l:sort = 1
				endif
				if match(l:flags, '\Cs') != -1
					let l:sort = 0
				endif
			endif
			if !isdirectory(s:IDE_Project[l:iter]['home'])
				let l:refresh = 0
			endif
			call add(l:idlist,l:iter)
			let l:torefresh[l:iter] = {'sorting':l:sort,'top':l:atTop,'refresh':l:refresh}
			"call s:IDE_InfoMsg('to refresh id='.l:iter.' sorting='.l:sort.' top='.l:atTop.' refresh='.l:refresh)
		endif
		let l:iter -= 1
	endwhile
	let l:cwd=getcwd()
	for pid in l:idlist
		"call s:IDE_InfoMsg("Refreshing project ".s:IDE_Project[pid]['name']." with ID=".pid)
		if l:torefresh[pid]['refresh']
			call s:IDE_RefreshEntry(pid,l:torefresh[pid]['sorting'],l:torefresh[pid]['top'],a:type)
		endif
	endfor
	exe 'cd '.l:cwd
	exe l:id
	normal! [z
endfunction
">>>
" === IDE_RefreshEntry(id) ===============================================<<<
" deleting lines will invalidate the internal map, do not use the s:IDE_File
" to refer to any line or jump across.
function! s:IDE_RefreshEntry(id,sort,top,type)
	call s:IDE_TraceLog("IDE_RefreshEntry(".a:id.",".a:sort.",".a:top.",".a:type.")")
	let l:id = a:id
	let l:home = s:IDE_Project[l:id]['home']
	let l:filter = s:IDE_Project[l:id]['filter']
	" jump to the initial line of this project
	let l:start = s:IDE_GetLocation(l:id)
	exe l:start
	let l:foldlev=foldlevel('.')
	" Open the fold, jump to the end and move upward once.
	normal! zo
	normal! ]z
	normal! k
	let l:curline = line('.')
	while l:curline > l:id
		"call s:IDE_InfoMsg("visiting line=".l:curline)
		exe l:curline
		if l:foldlev < foldlevel('.')
			if foldclosedend('.') == -1
				"fold is open, therefore we can jump to its begining
				normal! [z
			endif
		elseif l:foldlev == foldlevel('.')
			if (getline('.') !~ '^\s*#') && (getline('.') !~ '#.*pragma keep')
				"not a comment or a pragma keep line
				d _
			endif
		else
			call s:IDE_ErrorMsg("Projects had missing '{' or '}'")
		endif
		normal! k
		let l:curline = line('.')
	endwhile
	exe l:start
	if a:top == 0
		normal! ]zk
	endif
	let l:spaces=strpart('                                               ', 0, l:foldlev)
	if a:type==1
		" refresh the content of the project from its directory and filter
		exe 'cd '.l:home
		call s:IDE_DirListing(filter, l:spaces, 'b:files','b:dirs')
		if a:sort
			if (s:IDE_isSortWithCase)
				call sort(b:files)
			else
				call sort(b:files,1)
			endif
		endif
	else
		" reorder the content of the project from its current content
		" although the ID maps are incorrect we still have the information we need
		let b:files = []
		let l:stop = s:IDE_Project[l:id]['end']
		let l:it = l:id+1
		while l:it < l:stop
			if has_key(s:IDE_File,l:it) && s:IDE_File[l:it]['parent'] == l:id
				"we own the file
				call add(b:files,l:spaces.s:IDE_File[l:it]['name'])
			elseif has_key(s:IDE_Project,l:it)
				let l:it = s:IDE_Project[l:it]['end']
			endif
			let l:it += 1
		endwhile
		call s:IDE_LogMsg("Sorting (".len(b:files).") files in ide-project ".s:IDE_Project[l:id]['name'])
		if (s:IDE_isSortWithCase)
			call sort(b:files)
		else
			call sort(b:files,1)
		endif
	endif
	for afile in b:files
		silent! put =afile
	endfor
	unlet! b:files b:dirs
endfunction
">>>
" === IDE_DirListing(filter,padding,filevar,dirvar) ======================<<<
function! s:IDE_DirListing(filter, padding, filevariable, dirvariable)
	let l:end = 0
	let l:files=''
	let l:filter = a:filter
	" Chop up the filter
	"   Apparently glob() cannot take something like this: glob('*.c *.h')
	let l:while_var = 1
	while l:while_var
		let l:end = stridx(l:filter, ' ')
		if l:end == -1
			let l:end = strlen(l:filter)
			let l:while_var = 0
		endif
		let l:single=glob(strpart(l:filter, 0, l:end))
		if strlen(l:single) != 0
			let l:files = l:files.l:single."\010"
		endif
		let l:filter = strpart(l:filter, l:end + 1)
	endwhile
	" l:files now contains a list of everything in the directory. We need to
	" weed out the directories.
	let l:fnames=l:files
	let {a:filevariable}=[]
	let {a:dirvariable}=[]
	while strlen(l:fnames) > 0
		let l:fname = substitute(l:fnames,  '\(\(\f\|[ :\[\]]\)*\).*', '\1', '')
		let l:fnames = substitute(l:fnames, '\(\f\|[ :\[\]]\)*.\(.*\)', '\2', '')
		if isdirectory(glob(l:fname))
			call insert({a:dirvariable},a:padding.l:fname)
		else
			call insert({a:filevariable},a:padding.l:fname)
		endif
	endwhile
endfunction
">>>
" === Barely modified or unmodified project fuctions
" === IDE_FoldLeave_au() =================================================<<<
function! s:IDE_FoldLeave_au()
	"mkview
	"loadview
	"setlocal nofoldenable
	if s:IDE_foldProjectEntries
		silent! normal! zM
		silent! normal! zv
	endif
endfunction
">>>
" === Project Fold Text ==================================================<<<
"   The FoldText function for displaying just the description.
function! FoldText()
	let line=substitute(getline(v:foldstart),'^[ \t#]*\([^=]*\).*', '\1', '')
	let line=strpart('                                     ', 0, (v:foldlevel - 1)).substitute(line,'\s*{\+\s*', '', '')
	return line
endfunction
">>>
" === FoldTextSetup() ====================================================<<<
" === Project Setup ======================================================
"   Ensure everything is set up
function! s:FoldTextSetup()
	call s:IDE_TraceLog('FoldTextSetup()  #window='.s:IDE_userWindowWidth)
	call s:IDE_Assert(bufnr('%')==s:IDE_Buffer, "Not in the IDE buffer")
	setlocal foldenable
	setlocal foldmethod=marker
	setlocal foldmarker={,}
	setlocal commentstring=%s
	let l:foldcol=0
	if s:IDE_isEnableFoldColumn
		let l:foldcol=s:IDE_MaxDepth+1
	endif
	silent! exe 'setlocal foldcolumn='.l:foldcol
	setlocal shiftwidth=1
	setlocal foldtext=FoldText()
	if s:IDE_isShowLineNumber
		setlocal number
	else
		setlocal nonumber
	endif
	setlocal noswapfile
	setlocal nobuflisted
	setlocal nowrap
	exe 'setlocal winwidth='.s:IDE_userWindowWidth
endfunction
">>>
" === is absolute path? ==================================================<<<
"   Returns true if filename has an absolute path.
function! s:IsAbsolutePath(path)
	if a:path =~ '^ftp:' || a:path =~ '^rcp:' || a:path =~ '^scp:' || a:path =~ '^http:'
		return 2
	endif
	if a:path =~ '\$'
		let l:path=expand(a:path) " Expand any environment variables that might be in the path
	else
		let l:path=a:path
	endif
	if l:path[0] == '/' || l:path[0] == '~' || l:path[0] == '\\' || l:path[1] == ':'
		return 1
	endif
	return 0
endfunction
" >>>
" === DoWindowSetupAndSplit() ============================================<<<
" === setup and split ====================================================
"   Call DoWindowSetup to ensure the settings are correct.  Split to the next file.
" === assumes we are in focus!!, that is IDE_GetWindowState() == 1
function! s:DoWindowSetupAndSplit()
	call s:IDE_TraceLog('DoWindowSetupAndSplit()')
	call s:IDE_Assert((s:IDE_GetWindowState(g:IDE_Title)==1),"Not in focus")
	call s:FoldTextSetup()                " Ensure that all the settings are right
	let l:current = winnr()               " Determine if there is a CTRL_W-p window
	silent! wincmd p
	if l:current == winnr()
		exe s:IDE_cmd2WindowSide
	endif
	if l:current == winnr()
		" If l:current == winnr(), then there is no CTRL_W-p window
		" So we have to create a new one
		if bufnr('%') == s:IDE_Buffer
			exe 'silent vertical new'
		else
			exe 'silent vertical split | silent! bnext'
		endif
		" Go back to the Project Window and ensure it is at correct location and size
		wincmd p
		exe s:IDE_cmdLocate
		exe 'silent! vertical resize '.s:IDE_userWindowWidth
		wincmd p
	endif
endfunction
">>>
" === DoWindowSetupAndSplit_au() =========================================<<<
" === setup and split from autocommand ===================================
"   Same as above but ensure that the Project window is the current
"   window.  Only called from an autocommand
function! s:DoWindowSetupAndSplit_au()
	call s:IDE_TraceLog('DoWindowSetupAndSplit_au()')
	if winbufnr(0) != s:IDE_Buffer
		return
	endif
	if s:IDE_FileHasBeenClosed == 1 && winbufnr(2) == -1 &&  tabpagenr("$") != 1
		let s:IDE_FileHasBeenClosed = 0
		call s:IDE_ToggleClose()
		" after closing the IDE we should be in another tab and another buffer
		" the window number might be the same though
		" l:newbuf != bufnr(g:IDE_Title)
		let l:newbuf = winbufnr(winnr())
		call s:IDE_Toggle()
		" after opening the IDE, the window number for the buffers in the
		" current tab might have changed
		call s:IDE_ExeWithoutAucmds('silent! ' . s:GetWinNbr(tabpagenr("$"), newbuf) . 'wincmd w')
		" if everything went well, the current buffer is not the IDE buffer
		return
	endif
	call s:FoldTextSetup()          " Ensure that all the settings are right
	if winbufnr(2) == -1
		if tabpagenr("$") != 1
			call s:IDE_ToggleClose()
			call s:IDE_ToggleOpen()
			"call s:IDE_InfoMsg("Move to another tab to close this one.")
		else
			call s:IDE_ResizeWindow()
			call s:IDE_InfoMsg("Waiting... open a file or Close the project.")
		endif
		" We're the only window right now.
		"exe 'silent vertical split | bnext'
		"if bufnr('%') == s:IDE_Buffer
		"	enew
		"endif
		"if bufnr('%') == s:IDE_LastBuffer | bnext | bprev | bnext | endif
		"wincmd p " Go back to the Project Window and ensure it is the right width
		"exe s:IDE_cmdLocate
		"exe s:IDE_cmdResize
	elseif(winnr() != 1)
		exe s:IDE_cmdLocate
		exe 'silent! vertical resize '.s:IDE_userWindowWidth
	endif
	setlocal cursorline
endfunction
function! s:IDE_RecordLastBuffer_au()
	if bufexists('%') && bufloaded('%')
		let s:IDE_LastBuffer = bufnr('%')
	endif
endfunction
">>>
" === Construct the inherited directives =================================<<<
function! s:RecursivelyConstructDirectives(lineno)
	call s:IDE_TraceLog('RecusivelyConstructDirectives('.a:lineno.')')
	let l:lineno=s:FindFoldTop(a:lineno)
	let l:foldlineno = l:lineno
	let l:foldlev=foldlevel(l:lineno)
	let l:parent_infoline = ''
	if l:foldlev > 1
		while foldlevel(l:lineno) >= l:foldlev " Go to parent fold
			if l:lineno < 1
				call s:IDE_ErrorMsg('Fold error.  Check your syntax.')
				return
			endif
			let l:lineno = l:lineno - 1
		endwhile
		let l:parent_infoline = s:RecursivelyConstructDirectives(l:lineno)
	endif
	let l:parent_home = s:GetHome(l:parent_infoline, '')
	let l:parent_c_d = s:GetCd(l:parent_infoline, l:parent_home)
	let l:parent_scriptin = s:GetScriptin(l:parent_infoline, l:parent_home)
	let l:parent_scriptout = s:GetScriptout(l:parent_infoline, l:parent_home)
	let l:parent_filter = s:GetFilter(l:parent_infoline, '*')
	let l:infoline = getline(l:foldlineno)
	" Extract the home directory of this fold
	let l:home=s:GetHome(l:infoline, l:parent_home)
	if l:home != ''
		if (foldlevel(l:foldlineno) == 1) && !s:IsAbsolutePath(l:home)
			call confirm('Outermost ide-project fold must have absolute path!  Or perhaps the path does not exist.', "&OK", 1)
			let l:home = '~'  " Some 'reasonable' value
		endif
	endif
	" Extract any CD information
	let l:c_d = s:GetCd(l:infoline, l:home)
	if l:c_d != ''
		if (foldlevel(l:foldlineno) == 1) && !s:IsAbsolutePath(l:c_d)
			call confirm('Outermost ide-project fold must have absolute CD path!  Or perhaps the path does not exist.', "&OK", 1)
			let l:c_d = '.'  " Some 'reasonable' value
		endif
	else
		let l:c_d=l:parent_c_d
	endif
	" Extract scriptin
	let scriptin = s:GetScriptin(l:infoline, l:home)
	if scriptin == ''
		let scriptin = l:parent_scriptin
	endif
	" Extract scriptout
	let scriptout = s:GetScriptout(l:infoline, l:home)
	if scriptout == ''
		let scriptout = l:parent_scriptout
	endif
	" Extract filter
	let l:filter = s:GetFilter(l:infoline, l:parent_filter)
	if l:filter == '' | let l:filter = l:parent_filter | endif
	return s:ConstructInfo(l:home, l:c_d, scriptin, scriptout, '', l:filter)
endfunction
">>>
" === Construct information ==============================================<<<
function! s:ConstructInfo(home, c_d, scriptin, scriptout, flags, filter)
	call s:IDE_TraceLog('ConstructInfo('.a:home.','.a:c_d.','.a:scriptin.','.a:scriptout.','.a:flags.','.a:filter.')')
	let l:retval='Directory='.a:home
	if a:c_d[0] != ''
		let l:retval=l:retval.' CD='.a:c_d
	endif
	if a:scriptin[0] != ''
		let l:retval=l:retval.' in='.a:scriptin
	endif
	if a:scriptout[0] != ''
		let l:retval=l:retval.' out='.a:scriptout
	endif
	if a:filter[0] != ''
		let l:retval=l:retval.' filter="'.a:filter.'"'
	endif
	return l:retval
endfunction
">>>
" === Fold or open entry =================================================<<<
"   Used for double clicking. If the mouse is on a fold, open/close it. If
"   not, try to open the file.
function! s:DoFoldOrOpenEntry(editcmd)
	call s:IDE_TraceLog('DoFoldOrOpenEntry('.a:editcmd.')')
	call s:IDE_Assert((s:IDE_GetWindowState(g:IDE_Title)==1),"Not in the IDE buffer")
	if getline('.')=~'{\|}' || foldclosed('.') != -1 || has_key(s:IDE_Project,line('.'))
		normal! za
	else
		let l:line = line('.')
		if  foldlevel(l:line)==0
			" not in a project file line
			return 0
		endif
		if a:editcmd[0] == ''
			call s:IDE_WarnMsg('no command for file edition has been defined')
			return 0
		endif
		let id = s:IDE_GetID(l:line)
		call s:IDE_Assert((id >= s:IDE_ProjectID || id < s:IDE_ProjectEND),"Fold detected outside ide-project boundaries")
		"call s:DoEnsurePlacementSize_au()
		let l:retval=s:IDE_OpenFileEntry(id,a:editcmd)
		if s:IDE_isCloseOnOpen
			call s:IDE_LoseFocus()
		endif
	endif
endfunction
">>>
" === Generate a new Entry ===============================================<<<
function! s:GenerateEntry(recursive, line, name, absolute_dir, dir, c_d, filter_directive, filter, foldlev)
	let l:line=a:line
	if a:dir =~ '\\ '
		let l:dir='"'.substitute(a:dir, '\\ ', ' ', 'g').'"'
	else
		let l:dir=a:dir
	endif
	let l:spaces=strpart('                                                             ', 0, a:foldlev)
	let l:c_d=(strlen(a:c_d) > 0) ? 'CD='.a:c_d.' ' : ''
	let l:c_d=(strlen(a:filter_directive) > 0) ? l:c_d.'filter="'.a:filter_directive.'" ': l:c_d
	call append(l:line, l:spaces.'}')
	call append(l:line, l:spaces.a:name.'='.l:dir.' '.l:c_d.'{')
	if a:recursive
		exe 'cd '.a:absolute_dir
		call s:IDE_DirListing("*", '', 'b:files', 'b:dirs')
		cd -
		let dirs=b:dirs
		call sort(dirs)
		unlet! b:files b:dirs
		for adir in dirs
			let edname = escape(adir, ' ')
			let l:line=s:GenerateEntry(1, l:line + 1, adir, a:absolute_dir.'/'.edname, edname, '', '', a:filter, a:foldlev+1)
		endfor
	endif
	return l:line+1
endfunction
">>>
" === Generate the fold from the directory hierarchy (if recursive)=======<<<
" then fill it in with RefreshEntriesFromDir()
function! s:DoEntryFromDir(recursive, line, name, absolute_dir, dir, c_d, filter_directive, filter, foldlev)
	call s:GenerateEntry(a:recursive, a:line, a:name, escape(a:absolute_dir, ' '), escape(a:dir, ' '), escape(a:c_d, ' '), a:filter_directive, a:filter, a:foldlev)
	normal! j
	call s:RefreshEntriesFromDir(1)
endfunction
">>>
" === Prompts user for information and then calls s:DoEntryFromDir() =====<<<
function! s:IDE_CreateEntriesFrom(recursive)
	"                 0           1
	"a:recursive     off          on
	"a:type        from ide    from dir
	call s:IDE_BeforeEdit()
	call s:CreateEntriesFromDir(a:recursive)
	call s:IDE_AfterEdit()
endfunction
function! s:CreateEntriesFromDir(recursive)
	" Save a mark for the current cursor position
	normal! mk
	let l:line=line('.')
	echohl MoreMsg
	let l:name = input('IDE: Enter the name of the project entry  > ')
	echohl None
	if strlen(l:name) == 0
		return
	endif
	let l:foldlev=foldlevel(l:line)
	if (foldclosed(l:line) != -1) || (getline(l:line) =~ '}')
		let l:foldlev=l:foldlev - 1
	endif
	let l:absolute = (l:foldlev <= 0)?'Absolute ': ''
	let l:home=''
	let l:filter='*'
	if s:IDE_isUsingBrowse
		" Note that browse() is inconsistent: On Win32 you can't select a
		" directory, and it gives you a relative path.
		let l:dir = browse(0, 'IDE: Enter the '.l:absolute.' path of the directory to load ', '', '')
		let l:dir = fnamemodify(l:dir, ':p')
	else
		echohl MoreMsg
		let l:dir = input('IDE: Enter the '.l:absolute.' path of the directory to load > ', '')
		echohl None
	endif
	if (l:dir[strlen(l:dir)-1] == '/') || (l:dir[strlen(l:dir)-1] == '\\')
		let l:dir=strpart(l:dir, 0, strlen(l:dir)-1) " Remove trailing / or \
	endif
	let l:dir = substitute(l:dir, '^\~', $HOME, 'g')
	if (l:foldlev > 0)
		let parent_directive=s:RecursivelyConstructDirectives(l:line)
		let l:filter = s:GetFilter(parent_directive, '*')
		let l:home=s:GetHome(parent_directive, '')
		if l:home[strlen(l:home)-1] != '/' && l:home[strlen(l:home)-1] != '\\'
			let l:home=l:home.'/'
		endif
		unlet parent_directive
		if s:IsAbsolutePath(l:dir)
			" It is not a relative path  Try to make it relative
			let l:hend=matchend(l:dir, '\C'.glob(l:home))
			if l:hend != -1
				let l:dir=strpart(l:dir, l:hend)          " The directory can be a relative path
			else
				let l:home=""
			endif
		endif
	endif
	if strlen(l:home.l:dir) == 0
		return
	endif
	if !isdirectory(l:home.l:dir)
		if has('unix')
			silent exe '!mkdir '.l:home.l:dir.' > /dev/null'
		else
			call confirm('"'.l:home.l:dir.'" is not a valid directory.', "&OK", 1)
			return
		endif
	endif
	echohl MoreMsg
	let l:c_d = input('IDE: Enter the CD parameter > ', '')
	let l:filter_directive = input('IDE: Enter the file filter without quotes > ', '')
	echohl None
	if strlen(l:filter_directive) != 0
		let l:filter = l:filter_directive
	endif
	" If I'm on a closed fold, go to the bottom of it
	if foldclosedend(l:line) != -1
		let l:line = foldclosedend(l:line)
	endif
	let l:foldlev = foldlevel(l:line)
	" If we're at the end of a fold . . .
	if getline(l:line) =~ '}'
		let l:foldlev = l:foldlev - 1           " . . . decrease the indentation by 1.
	endif
	" Do the work
	call s:DoEntryFromDir(a:recursive, l:line, l:name, l:home.l:dir, l:dir, l:c_d, l:filter_directive, l:filter, l:foldlev)
	" Restore the cursor position
	normal! `k
endfunction
">>>
" === Finds metadata at the top of the fold, and then replaces all files =<<<
" with the contents of the directory.  Works recursively if recursive is 1.
function! s:RefreshEntriesFromDir(recursive)
	if foldlevel('.') == 0
		call s:IDE_InfoMsg('Nothing to refresh.')
		return
	endif
	" Open the fold.
	if getline('.') =~ '}'
		normal! zo[z
	else
		normal! zo]z[z
	endif
	let l:just_a_fold=0
	let l:infoline = s:RecursivelyConstructDirectives(line('.'))
	let l:immediate_infoline = getline('.')
	if strlen(substitute(l:immediate_infoline, '[^=]*=\(\(\f\|:\|\\ \)*\).*', '\1', '')) == strlen(l:immediate_infoline)
		let l:just_a_fold = 1
	endif
	" Extract the home directory of the fold
	let l:home = s:GetHome(l:infoline, '')
	if l:home == ''
		" No Match.  This means that this is just a label with no
		" directory entry.
		if a:recursive == 0
			return          " We're done--nothing to do
		endif
		" Mark that it is just a fold, so later we don't delete filenames
		" that aren't there.
		let l:just_a_fold = 1
	endif
	if l:just_a_fold == 0
		" Extract the filter between quotes (we don't care what CD is).
		let filter = s:GetFilter(l:infoline, '*')
		" Extract the description (name) of the fold
		let l:name = substitute(l:infoline, '^[#\t ]*\([^=]*\)=.*', '\1', '')
		if strlen(l:name) == strlen(l:infoline)
			return                  " If there's no name, we're done.
		endif
		if (l:home == '') || (l:name == '')
			return
		endif
		" Extract the flags
		let l:flags = s:GetFlags(l:immediate_infoline)
		let l:sort = s:IDE_isSortingOn
		if l:flags != ''
			if match(l:flags, '\Cr') != -1
				" If the flags do not contain r (refresh), then treat it just like a fold
				let l:just_a_fold = 1
			endif
			if match(l:flags, '\CS') != -1
				let l:sort = 1
			endif
			if match(l:flags, '\Cs') != -1
				let l:sort = 0
			endif
		else
			let l:flags=''
		endif
	endif
	" Move to the first non-fold boundary line
	normal! j
	" Delete filenames until we reach the end of the fold
	while getline('.') !~ '}'
		if line('.') == line('$')
			break
		endif
		if getline('.') !~ '{'
			" We haven't reached a sub-fold, so delete what's there.
			if (l:just_a_fold == 0) && (getline('.') !~ '^\s*#') && (getline('.') !~ '#.*pragma keep')
				d _
			else
				" Skip lines only in a fold and comment lines
				normal! j
			endif
		else
			" We have reached a sub-fold. If we're doing recursive, then
			" call this function again. If not, find the end of the fold.
			if a:recursive == 1
				call s:RefreshEntriesFromDir(1)
				normal! ]zj
			else
				if foldclosed('.') == -1
					normal! zc
				endif
				normal! j
			endif
		endif
	endwhile
	if l:just_a_fold == 0
		" We're not just in a fold, and we have deleted all the filenames.
		" Now it is time to regenerate what is in the directory.
		if !isdirectory(glob(l:home))
			call confirm('"'.l:home.'" is not a valid directory.', "&OK", 1)
		else
			let l:foldlev=foldlevel('.')
			" T flag.  Thanks Tomas Z.
			if (match(l:flags, '\Ct') != -1) || (!s:IDE_isSubProjectToTop && (match(l:flags, '\CT') == -1))
				" Go to the top of the fold (force other folds to the bottom)
				normal! [z
				normal! j
				" Skip any comments
				while getline('.') =~ '^\s*#'
					normal! j
				endwhile
			endif
			normal! k
			let l:cwd=getcwd()
			let l:spaces=strpart('                                               ', 0, l:foldlev)
			exe 'cd '.l:home
			if s:IDE_isShowingInfo
				echon l:home."\r"
			endif
			call s:IDE_DirListing(filter, l:spaces, 'b:files','b:dirs')
			if (s:IDE_isSortWithCase)
				call sort(b:files)
			else
				call sort(b:files,1)
			endif
			for afile in b:files
				silent! put =afile
			endfor
			normal! j
			unlet! b:files b:dirs
			exe 'cd '.l:cwd
		endif
	endif
	" Go to the top of the refreshed fold.
	normal! [z
endfunction
">>>
" === Moves the entity under the cursor up a line ========================<<<
function! s:MoveUp()
	let l:lineno=line('.')
	let l:id = s:IDE_GetID(l:lineno)-1
	if  l:id <= s:IDE_ProjectID
		return
	endif
	call s:IDE_BeforeEdit()
	let fc=foldclosed('.')
	let x_reg=@x
	if l:lineno == line('$')
		"remove the line and place it on register x, then paste the register x
		normal! "xdd"xP
	else
		"remove the line and place it on register x, move upwards and then paste the register x
		normal! "xddk"xP
	endif
	let @x=x_reg
	if fc != -1
		normal! zc
	endif
	call s:IDE_AfterEdit()
endfunction
">>>
" === Moves the entity under the cursor down a line ======================<<<
function! s:MoveDown()
	let l:lineno=line('.')
	let l:id = s:IDE_GetID(l:lineno)
	if  l:id <= s:IDE_ProjectID
		return
	endif
	call s:IDE_BeforeEdit()
	let fc=foldclosed('.')
	let x_reg=@x
	normal! "xdd"xp
	let @x=x_reg
	if (fc != -1) && (foldclosed('.') == -1)
		normal! zc
	endif
	call s:IDE_AfterEdit()
endfunction
">>>
" === Displays filename and current working directory when i is in flags =<<<
function! s:DisplayInfo()
	if s:IDE_isShowingInfo
		call s:IDE_InfoMsg('file: '.expand('%').', cwd: '.getcwd().', lines: '.line('$'))
	endif
endfunction
">>>
" === Sets up an autocommand to ensure that the cwd is set correctly =====<<<
" to the one desired for the fold regardless.  :lcd only does this on
" a per-window basis, not a per-buffer basis.
function! s:SetupAutoCommand(cwd)
	if !exists("b:proj_has_autocommand")
		let b:proj_cwd_save = escape(getcwd(), ' ')
		let b:proj_has_autocommand = 1
		let l:bufname=escape(substitute(expand('%:p', 0), '\\', '/', 'g'), ' ')
		exe 'au BufEnter '.l:bufname." let b:proj_cwd_save=escape(getcwd(), ' ') | cd ".a:cwd
		exe 'au BufLeave '.l:bufname.' exe "cd ".b:proj_cwd_save'
		exe 'au BufWipeout '.l:bufname.' au! * '.l:bufname
	endif
endfunction
">>>
" === Sets up an autocommand to run the scriptin script ==================<<<
function! s:SetupScriptAutoCommand(bufcmd, script)
	if !exists("b:proj_has_".a:bufcmd)
		let b:proj_has_{a:bufcmd} = 1
		exe 'au '.a:bufcmd.' '.escape(substitute(expand('%:p', 0), '\\', '/', 'g'), ' ').' source '.a:script
	endif
endfunction
" >>>
" === Ensure that the Project window is on the left of the window ========<<<
" and has the correct size. Only called from an autocommand
function! s:DoEnsurePlacementSize_au()
	if (winbufnr(0) != s:IDE_Buffer) || (s:IDE_isAtRightWindow && winnr() != winnr('$')) || (!s:IDE_isAtRightWindow && winnr() != 1)
		exe s:IDE_cmdLocate
	endif
	exe 'silent! vertical resize '.s:IDE_userWindowWidth
endfunction
">>>
" === Spawn an external command on the file ==============================<<<
function! s:Spawn(number)
	echo | if exists("g:proj_run".a:number)
		let l:id = s:IDE_GetID(line('.'))
		if has_key(s:IDE_File,l:id)
			let l:fname=s:IDE_File[l:id]['name']
			let l:parent_id=s:IDE_File[l:id]['parent']
			let l:fname=s:IDE_GetFileName(l:fname,l:parent_id)
			let l:home = s:IDE_Project[l:paren_id]['home']
			let l:c_d = s:IDE_Project[l:parent_id]['cd']
			let l:command=substitute(g:proj_run{a:number}, '%%', "\010", 'g')
			let l:command=substitute(l:command, '%f', escape(l:home.'/'.l:fname, '\'), 'g')
			let l:command=substitute(l:command, '%F', substitute(escape(l:home.'/'.l:fname, '\'), ' ', '\\\\ ', 'g'), 'g')
			let l:command=substitute(l:command, '%s', escape(l:home.'/'.l:fname, '\'), 'g')
			let l:command=substitute(l:command, '%n', escape(l:fname, '\'), 'g')
			let l:command=substitute(l:command, '%N', substitute(l:fname, ' ', '\\\\ ', 'g'), 'g')
			let l:command=substitute(l:command, '%h', escape(l:home, '\'), 'g')
			let l:command=substitute(l:command, '%H', substitute(escape(l:home, '\'), ' ', '\\\\ ', 'g'), 'g')
			if l:c_d != ''
				if l:c_d == l:home
					let percent_r='.'
				else
					let percent_r=substitute(l:home, escape(l:c_d.'/', '\'), '', 'g')
				endif
			else
				let percent_r=l:home
			endif
			let l:command=substitute(l:command, '%r', percent_r, 'g')
			let l:command=substitute(l:command, '%R', substitute(percent_r, ' ', '\\\\ ', 'g'), 'g')
			let l:command=substitute(l:command, '%d', escape(l:c_d, '\'), 'g')
			let l:command=substitute(l:command, '%D', substitute(escape(l:c_d, '\'), ' ', '\\\\ ', 'g'), 'g')
			let l:command=substitute(l:command, "\010", '%', 'g')
			exe l:command
		endif
	endif
endfunction
">>>
" === List external commands =============================================<<<
function! s:ListSpawn(varnamesegment)
	let number = 1
	while number < 10
		if exists("g:proj_run".a:varnamesegment.number)
			echohl LineNr | echo number.':' | echohl None | echon ' '.substitute(escape(g:proj_run{a:varnamesegment}{number}, '\'), "\n", '\\n', 'g')
		else
			echohl LineNr | echo number.':' | echohl None
		endif
		let number=number + 1
	endwhile
endfunction
">>>
" === Return the line number of the directive line =======================<<<
function! s:FindFoldTop(line)
	let l:lineno=a:line
	if getline(l:lineno) =~ '}'
		let l:lineno = l:lineno - 1
	endif
	while getline(l:lineno) !~ '{' && l:lineno > 1
		if getline(l:lineno) =~ '}'
			let l:lineno=s:FindFoldTop(l:lineno)
		endif
		let l:lineno = l:lineno - 1
	endwhile
	return l:lineno
endfunction
">>>
" === Return the line number of the directive line =======================<<<
function! s:FindFoldBottom(line)
	let l:lineno=a:line
	if getline(l:lineno) =~ '{'
		let l:lineno=l:lineno + 1
	endif
	while getline(l:lineno) !~ '}' && l:lineno < line('$')
		if getline(l:lineno) =~ '{'
			let l:lineno=s:FindFoldBottom(l:lineno)
		endif
		let l:lineno = l:lineno + 1
	endwhile
	return l:lineno
endfunction
">>>
" === Wipe all files in a project ========================================<<<
function! s:IDE_WipeAllFilesInProject_atline(recurse)
	call s:WipeAll(a:recurse,line('.'))
endfunction
function! s:WipeAll(recurse,at_line)
	let b:wipecount=0
	let b:totalcount=0
	function! s:SpawnExec(id, data)
		let l:filename=s:IDE_File[a:id]['name']
		let l:parent_id=s:IDE_File[a:id]['parent']
		let l:home=s:IDE_Project[l:parent_id]['home']
		if !s:IsAbsolutePath(l:filename)
			let l:filename=l:home.'/'.l:filename
		endif
		let l:filename = s:IDE_GetConsistentFileName(l:filename)
		let l:bufNbr = bufnr(l:filename)
		let b:totalcount=b:totalcount+1
		if bufloaded(l:bufNbr) &&  !getbufvar(l:bufNbr, '&modified')
			let b:wipecount=b:wipecount+1
			exe 'bwipe! '.l:filename
		endif
		if b:totalcount % 5 == 0
			call s:IDE_InfoMsg("closed ".b:wipecount.' out of '.b:totalcount." files")
		endif
		if getchar(0) != 0
			let b:stop_everything=1
		endif
	endfunction
	let l:id = s:IDE_GetID(a:at_line)
	call s:IDE_ForEachFileInProject(a:recurse, l:id, "<SID>SpawnExec", 0, '^\(.*w\)\@!')
	delfunction s:SpawnExec
	call s:IDE_InfoMsg(b:wipecount.' of '.b:totalcount.' Files Wiped')
	unlet b:wipecount b:totalcount
	if exists("b:stop_everything") | unlet b:stop_everything | endif
endfunction
">>>
" === Grep all files in a project, optionally recursively ================<<<
function! s:IDE_GrepAllFilesInProject_atline(recurse,pattern)
	let l:at_line = line('.')
	echohl MoreMsg
	let l:pattern=(a:pattern[0] == '')?input("GREP options and pattern: "):a:pattern
	echohl None
	if l:pattern[0] == ''
		return
	endif
	let l:id = s:IDE_GetID(l:at_line)
	let l:id = s:IDE_GetThisProjectBegin(l:id)
	call s:GrepAll(l:id,l:pattern,a:recurse)
endfunction
function! s:GrepAll(proj_id, pattern, recurse)
	call s:IDE_TraceLog("GrepAll(".a:proj_id.",".a:pattern.",".a:recurse.")")
	let l:fnames=s:IDE_GetProjectFiles(a:proj_id,a:recurse)
	cclose " Make sure grep window is closed
	if s:IDE_GetWindowState(g:IDE_Title) == 1
		call s:DoWindowSetupAndSplit()
	endif
	call s:IDE_TraceLog("grep files = [".l:fnames."]")
	if s:IDE_isVimGrep
		silent! exe 'silent! vimgrep '.a:pattern.' '.l:fnames
		copen
	else
		silent! exe 'silent! grep '.a:pattern.' '.l:fnames
		if v:shell_error != 0
			echohl ErrorMsg
			call s:IDE_ErrorMsg('IDE Error: External GREP on '.len(l:fnames).' failed.')
			echohl None
		else
			copen
		endif
	endif
endfunction
">>>
" === IDE_GetProjectFiles() ==============================================<<<
function! s:IDE_GetProjectFiles(id,recurse)
	call s:IDE_Assert(has_key(s:IDE_Project,a:id),"Not at the begining of a project")
	call s:IDE_TraceLog("IDE_GetProjectFiles(".a:id.",".a:recurse.")")
	let l:allfiles = ''
	let l:eof = s:IDE_Project[a:id]['end']
	let l:id = a:id + 1
	while l:id < l:eof
		if has_key(s:IDE_Project,l:id) && !a:recurse
			let l:id = s:IDE_Project[l:id]['end']
		elseif has_key(s:IDE_File,l:id)
			let l:filename = s:IDE_File[l:id]['name']
			let l:parent = s:IDE_File[l:id]['parent']
			let l:home = s:IDE_Project[l:parent]['home']
			if !s:IsAbsolutePath(l:filename)
				let l:filename=l:home.'/'.l:filename
			endif
			let l:filename = escape(s:IDE_GetConsistentFileName(l:filename),' ')
			let l:allfiles .= " ".l:filename
		endif
		let l:id += 1
	endwhile
	return l:allfiles
endfunction
">>>
" === GetXXX Functions
" === Get Home ===========================================================<<<
function! s:GetHome(info, parent_home)
	call s:IDE_TraceLog('GetHome('.a:info.','.a:parent_home.')')
	if a:info != ''
		let l:check=substitute(a:info,'^[^=]*=\([^\ ]*\).*','\1','')
		if l:check==''
			let l:name = substitute(a:info,'^\([^=]*\)=','\1','')
			call s:IDE_ErrorMsg("ide-project \"".l:name."\" has no path")
		endif
	endif
	" Thanks to Adam Montague for pointing out the need for @ in urls.
	let l:home=substitute(a:info, '^[^=]*=\(\(\\ \|\f\|:\|@\)\+\).*', '\1', '')
	if strlen(l:home) == strlen(a:info)
		let l:home=substitute(a:info, '.\{-}"\(.\{-}\)".*', '\1', '')
		if strlen(l:home) != strlen(a:info)
			let l:home=escape(l:home, ' ')
		endif
	endif
	"if strlen(l:home) == strlen(a:info)
	"	let l:home=a:parent_home
	"else
	if l:home=='.' || l:home==''
		if a:parent_home==''
			let l:home=getcwd()
		else
			let l:home=a:parent_home
		endif
	elseif !s:IsAbsolutePath(l:home)
		let l:home=a:parent_home.'/'.l:home
		let l:home=s:IDE_GetConsistentFileName(l:home)
	endif
	" return an absolute path always
	return l:home
endfunction
">>>
" === Get Filter =========================================================<<<
function! s:GetFilter(info, parent_filter)
	let l:filter = substitute(a:info, '.*\<filter="\([^"]*\).*', '\1', '')
	if strlen(l:filter) == strlen(a:info) | let l:filter = a:parent_filter | endif
	return l:filter
endfunction
">>>
" === Get Project name ===================================================<<<
function! s:IDE_GetProjectName(info,lineno)
	"pattern \{-n} match exactly n
	let l:name = substitute(a:info, '^\([^=]*\)=\{-1}.*', '\1', '')
	if strlen(l:name) == 0
		let l:name = "UnNamedProjectAtLine".a:lineno
	endif
	return l:name
endfunction
">>>
" === Get CD =============================================================<<<
function! s:GetCd(info, home)
	call s:IDE_TraceLog('s:GetCd('.a:info.','.a:home.')')
	let l:c_d=substitute(a:info, '.*\<CD=\(\(\\ \|\f\|:\)\+\).*', '\1', '')
	if strlen(l:c_d) == strlen(a:info)
		let l:c_d=substitute(a:info, '.*\<CD="\(.\{-}\)".*', '\1', '')
		if strlen(l:c_d) != strlen(a:info) | let l:c_d=escape(l:c_d, ' ') | endif
	endif
	if strlen(l:c_d) == strlen(a:info)
		let l:c_d=''
	elseif l:c_d == '.'
		let l:c_d = a:home
	elseif !s:IsAbsolutePath(l:c_d)
		let l:c_d = a:home.'/'.l:c_d
	endif
	return l:c_d
endfunction
">>>
" === Get Script in ======================================================<<<
function! s:GetScriptin(info, home)
	let scriptin = substitute(a:info, '.*\<in=\(\(\\ \|\f\|:\)\+\).*', '\1', '')
	if strlen(scriptin) == strlen(a:info)
		let scriptin=substitute(a:info, '.*\<in="\(.\{-}\)".*', '\1', '')
		if strlen(scriptin) != strlen(a:info) | let scriptin=escape(scriptin, ' ') | endif
	endif
	if strlen(scriptin) == strlen(a:info)
		let scriptin=''
	else
		if !s:IsAbsolutePath(scriptin) | let scriptin=a:home.'/'.scriptin | endif
	endif
	return scriptin
endfunction
">>>
" === Get Script out =====================================================<<<
function! s:GetScriptout(info, home)
	let scriptout = substitute(a:info, '.*\<out=\(\(\\ \|\f\|:\)\+\).*', '\1', '')
	if strlen(scriptout) == strlen(a:info)
		let scriptout=substitute(a:info, '.*\<out="\(.\{-}\)".*', '\1', '')
		if strlen(scriptout) != strlen(a:info) | let scriptout=escape(scriptout, ' ') | endif
	endif
	if strlen(scriptout) == strlen(a:info)
		let scriptout=''
	else
		if !s:IsAbsolutePath(scriptout) | let scriptout=a:home.'/'.scriptout | endif
	endif
	return scriptout
endfunction
">>>
" === Get Flags ==========================================================<<<
function! s:GetFlags(info)
	let l:flags=substitute(a:info, '.*\<flags=\([^ {]*\).*', '\1', '')
	if (strlen(l:flags) == strlen(a:info))
		let l:flags=''
	endif
	return l:flags
endfunction
">>>
" === Get all files in a project, optionally recursively =================<<<
function! s:IDE_GetAllFileNames(recurse, lineno, separator)
	let b:fnamelist=''
	function! s:SpawnExec(id, data)
		call s:IDE_TraceLog("IDE_GetAllFileNames::<SpawnExec>(".a:id.",".a:data.")")
		let l:filename=s:IDE_File[a:id]['name']
		let l:parent_id=s:IDE_File[a:id]['parent']
		let l:home=s:IDE_Project[l:parent_id]['home']
		if !s:IsAbsolutePath(l:filename)
			let l:filename=l:home.'/'.l:filename
		endif
		let l:filename = escape(s:IDE_GetConsistentFileName(l:filename),' ')
		let b:fnamelist=b:fnamelist.a:data.l:filename
	endfunction
	let l:id = s:IDE_GetID(a:lineno)
	call s:IDE_ForEachFileInProject(a:recurse, l:id, "<SID>SpawnExec", a:separator, '')
	delfunction s:SpawnExec
	let l:retval=b:fnamelist
	unlet b:fnamelist
	return l:retval
endfunction
">>>
" === For each sub project in a project, optionally recursively ==========<<<
function! s:IDE_ForEachProject(recurse, lineno, cmd, depth, match)
	let info=s:RecursivelyConstructDirectives(a:lineno)
	let l:lineno=s:FindFoldTop(a:lineno) + 1
	let l:flags=s:GetFlags(getline(l:lineno - 1))
	if (l:flags == '') || (a:match=='') || (match(l:flags, a:match) != -1)
		call s:IDE_ForEachProjectRecursively(a:recurse, l:lineno, info, a:cmd, a:depth+1, a:match)
	endif
endfunction
">>>
" === For each sub project in a project, recursively =====================<<<
function! s:IDE_ForEachProjectRecursively(recurse, lineno, info, cmd, depth, match)
	let l:home=s:GetHome(a:info, '')
	let l:c_d=s:GetCd(a:info, l:home)
	let l:filter = s:GetFilter(a:info, '')
	let l:lineno = a:lineno
	let curline=getline(l:lineno)
	while (curline !~ '}') && (curline < line('$'))
		if exists("b:stop_everything") && b:stop_everything | return 0 | endif
		if curline =~ '{'
			let this_flags=s:GetFlags(curline)
			let this_home=s:GetHome(curline, l:home)
			let this_cd=s:GetCd(curline, this_home)
			if this_cd=='' | let this_cd=l:c_d | endif
			let this_scriptin=''
			let this_scriptout=''
			let this_filter=s:GetFilter(curline, l:filter)
			let this_name=s:IDE_GetProjectName(curline,l:lineno)
			let this_proj = {"home":this_home,"cd":this_cd,"flags":this_flags,"filter":this_filter}
			let l:this_info = s:ConstructInfo(this_home, this_cd, this_scriptin, this_scriptout, this_flags, this_filter)
			if a:cmd[0] == '*'
				call {strpart(a:cmd, 1)}(a:info, l:this_info, l:lineno, a:depth)
			else
				call {a:cmd}(l:lineno, this_name, this_proj, a:depth, '')
			endif
			if a:recurse
				if (this_flags == '') || (a:match=='') || (match(this_flags, a:match) != -1)
					let l:lineno=s:IDE_ForEachProjectRecursively(1, l:lineno+1, l:this_info, a:cmd, a:depth+1, a:match)
				else
					let l:lineno=s:FindFoldBottom(l:lineno)
				endif
			else
				let l:lineno=s:FindFoldBottom(l:lineno)
			endif
		else
			"skip all files
			"have to go through the lines though as there might be another
			"sub sub project in there
		endif
		let l:lineno=l:lineno + 1
		let curline=getline(l:lineno)
	endwhile
	return l:lineno
endfunction
">>>
" === Spawn an external command on the files of a project ================<<<
function! s:SpawnAll(recurse, number)
	echo | if exists("g:proj_run_fold".a:number)
		if g:proj_run_fold{a:number}[0] == '*'
			function! s:SpawnExec(id, data)
				let l:fname=s:IDE_File[a:id]['name']
				let l:parent_id=s:IDE_File[a:id]['parent']
				let l:home=s:IDE_Project[l:parent_id]['home']
				let l:c_d=s:IDE_Project[l:parent_id]['cd']
				let l:command=substitute(strpart(g:proj_run_fold{a:data}, 1), '%s', escape(l:fname, ' \'), 'g')
				let l:command=substitute(l:command, '%f', escape(l:fname, '\'), 'g')
				let l:command=substitute(l:command, '%h', escape(l:home, '\'), 'g')
				let l:command=substitute(l:command, '%d', escape(l:c_d, '\'), 'g')
				let l:command=substitute(l:command, '%F', substitute(escape(l:fname, '\'), ' ', '\\\\ ', 'g'), 'g')
				exe l:command
			endfunction
			let l:id = s:IDE_GetID(line('.'))
			call s:IDE_ForEachFileInProject(a:recurse, l:id, "<SID>SpawnExec", a:number, '.')
			delfunction s:SpawnExec
		else
			let l:id = s:IDE_GetID(line('.'))
			let l:home=s:GetHome(info, '')
			let l:c_d=s:GetCd(info, '')
			let l:fnames=s:IDE_GetAllFileNames(a:recurse, line('.'), ' ')
			let l:command=substitute(g:proj_run_fold{a:number}, '%f', substitute(escape(l:fnames, '\'), '\\ ', ' ', 'g'), 'g')
			let l:command=substitute(l:command, '%s', escape(l:fnames, '\'), 'g')
			let l:command=substitute(l:command, '%h', escape(l:home, '\'), 'g')
			let l:command=substitute(l:command, '%d', escape(l:c_d, '\'), 'g')
			let l:command=substitute(l:command, '%F', escape(l:fnames, '\'), 'g')
			exe l:command
			if v:shell_error != 0
				echo 'Shell error. Perhaps there are too many filenames.'
			endif
		endif
	endif
endfunction
">>>
"================ Winmanager integration =============================================
" === IDE_start() ========================================================<<<
" Initialization required for integration with winmanager
function! IDE_start()
	" If current buffer is not IDE buffer, then don't proceed
	if bufname('%') != '__IDE_project__'
		return
	endif

	let s:IDE_AppName = 'winmanager'

	" Get the current filename from the winmanager plugin
	let bufnum = WinManagerGetLastEditedFile()
	if bufnum != -1
		let l:filename = fnamemodify(bufname(bufnum), ':p')
		"let ftype = s:IDE_Get_Buffer_Filetype(bufnum)
	endif

	" Initialize the IDE window, if it is not already initialized
	if !exists('s:IDE_isWindowInitialized') || !s:IDE_isWindowInitialized
		call s:initWindowIDE()
		call s:IDE_RefreshWindow()
		let s:IDE_isWindowInitialized = 1
	endif
endfunction
">>>
" === IDE_Refresh() ======================================================<<<
" === Refresh the IDE
function! s:IDE_Refresh()
	call s:IDE_TraceLog('IDE_Refresh()')
	" If part of the winmanager plugin and not configured to process
	" tags always and not configured to display the tags menu, then return
	if (s:IDE_AppName == 'winmanager') && s:IDE_updateWinManagerAlways
		return
	endif
	" Skip buffers with 'buftype' set to nofile, nowrite, quickfix or help
	if &buftype != ''
		return
	endif
	"let filename = fnamemodify(bufname('%'), ':p')
	let IDE_win = bufwinnr(g:IDE_Title)
	" If the IDE window is not opened and not configured to process
	" tags always and not displaying the tags menu, then return
	if IDE_win == -1 && !s:IDE_updateWinManagerAlways
		return
	endif
	" Update the IDE window
	if IDE_win != -1
		" Disable screen updates
		let old_lazyredraw = &lazyredraw
		set nolazyredraw
		" Save the current window number
		let save_winnr = winnr()
		" Goto the IDE window
		call s:IDE_GainFocusIfOpenInWindows()
		let save_line = line('.')
		let save_col = col('.')
		" Restore the cursor position
		if v:version >= 601
			call cursor(save_line, save_col)
		else
			exe save_line
			exe 'normal! ' . save_col . '|'
		endif
		" Jump back to the original window
		if save_winnr != winnr()
			call s:IDE_ExeWithoutAucmds(save_winnr . 'wincmd w')
		endif
		" Restore screen updates
		let &lazyredraw = old_lazyredraw
	endif
endfunction
">>>
" === IDE_isValid() ======================================================<<<
function! IDE_IsValid()
	return 0
endfunction
">>>
" === IDE_isValid() ======================================================<<<
function! IDE_WrapUp()
	return 0
endfunction
">>>

" restore 'cpo'
let &cpoptions = s:cpo_save
unlet s:cpo_save

finish

" vim600: set foldmethod=marker foldmarker=<<<,>>> foldlevel=1:
"
