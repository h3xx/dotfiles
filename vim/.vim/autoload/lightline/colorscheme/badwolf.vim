let s:red      = '#ff2c4b'
let s:green    = '#aeee00'
let s:blue     = '#0a9dff'
let s:orange   = '#ffa724'
let s:c_red    = '196'
let s:c_green  = '154'
let s:c_blue   = '39'
let s:c_orange = '214'

let s:white    = '#f8f6f2'
let s:c_white  = '15'

let s:black1   = '#242321'
let s:black2   = '#35322d'
let s:black3   = '#45413b'
let s:black4   = '#857f78'
let s:c_black1 = '235'
let s:c_black2 = '236'
let s:c_black3 = '233'
let s:c_black4 = '243'

let s:p = { 'normal':{}, 'inactive':{}, 'insert':{}, 'replace':{}, 'visual':{}, 'tabline':{} }

"guifg, guibg, ctermfg, ctermbg

"normal mode
let s:p.normal.middle = [
            \ [s:white, s:black1, s:c_white, s:c_black1]
            \ ]
let s:p.normal.left = [
            \ [s:black1, s:green, s:c_black1, s:c_green],
            \ [ s:white, s:black2, s:c_white, s:c_black2 ]
            \ ]
let s:p.normal.right = [
            \ [s:black4, s:white, s:c_black4, s:c_white],
            \ [ s:white, s:black2, s:c_white, s:c_black2 ]
            \ ]

"insert mode
let s:p.insert.left = [
            \ [s:white, s:blue, s:c_white, s:c_blue],
            \ [ s:white, s:black2, s:c_white, s:c_black2 ]
            \ ]

"visual mode
let s:p.visual.left = [
            \ [s:white, s:orange, s:c_white, s:c_orange],
            \ [ s:white, s:black2, s:c_white, s:c_black2 ]
            \ ]

"replace mode
let s:p.replace.left = [
            \ [s:white, s:red, s:c_white, s:c_red],
            \ [ s:white, s:black2, s:c_white, s:c_black2 ]
            \ ]

"buffer inactive
let s:p.inactive.middle = [
            \ [s:white, s:black2, s:c_white, s:c_black2]
            \ ]
let s:p.inactive.right = [
            \ s:p.inactive.middle[0],
            \ s:p.inactive.middle[0]
            \ ]
let s:p.inactive.left = [
            \ s:p.inactive.middle[0],
            \ s:p.inactive.middle[0]
            \ ]

"tabline
let s:p.tabline.middle = [
            \ [s:white, s:black2, s:c_white, s:c_black2]
            \ ]
let s:p.tabline.right = [
            \ [s:white, s:black2, s:c_white, s:c_black2]
            \ ]
let s:p.tabline.left = [
            \ [s:black4, s:black2, s:c_black4, s:c_black2]
            \ ]
"current tab
let s:p.tabline.tabsel = [
            \ [s:black1, s:green, s:c_white, s:c_black4]
            \ ]

let g:lightline#colorscheme#badwolf#palette = s:p
