if @% =~# '^/tmp/bash-fc\.'
	" Don't keep metadata around for Bash edit-and-execute-command (C-x C-e) files
	setl nobk noswf noudf
elseif expand('%:t') =~# '^\.bash\(rc\|_profile\)'
	" Keep tabs intact for oft-sourced files
	setl noet
endif
