" insert the current filename without the .php extension
"put =expand('%:t:r')
" (better version - replace current WORD with filename without the .php extension)
exe "norm \"_ciW\<C-r>=expand(\"%:t:r\")\<CR>"
