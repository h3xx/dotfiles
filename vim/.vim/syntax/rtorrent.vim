" Vim Syntax file for rtorrent.rc
" Author: Chris Carpita <ccarpita@gmail.com>
" Version: 0.1
" Revised: May, 2008

if !exists("main_syntax")
	let main_syntax='rtorrent'
endif

syn match rtorrentComment "#.*$"

syn keyword rtorrentSetting  min_peers max_peers min_peers_seed max_peers_seed max_uploads download_rate upload_rate directory session schedule ip bind port_range port_random check_hash use_udp_trackers encryption dht dht_port peer_exchange hash_read_ahead hash_interval hash_max_tries contained

syn match rtorrentOp "=" contained

syn match rtorrentStatement "\s*\w\+\s*=\s*.*$" contains=rtorrentSettingAttempt,rtorrentOp

syn match rtorrentSettingAttempt "^\s*\w\+" contains=rtorrentSetting contained

if !exists('HiLink') 
	command! -nargs=+ HiLink hi link <args>
endif

HiLink rtorrentSettingAttempt String
HiLink rtorrentStatement Type
HiLink rtorrentComment Comment
HiLink rtorrentSetting Operator
HiLink rtorrentOp	   Special
