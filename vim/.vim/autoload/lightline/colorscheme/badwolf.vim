let s:N1 = [ 232 , 154 ] " blackestgravel & lime
let s:N2 = [ 222 , 238 ] " dirtyblonde    & deepgravel
let s:N3 = [ 121 , 235 ] " saltwatertaffy & darkgravel
let s:N4 = [ 241 ]       " mediumgravel

let s:I1 = [ 232 , 39  ] " blackestgravel & tardis
let s:I2 = [ 222 , 27  ] " dirtyblonde    & facebook
let s:I3 = [ 39  , 235 ] " tardis         & darkgravel

let s:V1 = [ 232 , 214 ] " blackestgravel & orange
let s:V2 = [ 16  , 221 ] " coal           & dalespale
let s:V3 = [ 16  , 137 ] " coal           & toffee
let s:V4 = [ 173 ]       " coffee

let s:T1 = [ 232 , 214 ] " blackestgravel & darkorange
let s:T2 = [ 222 , 235 ] " dirtyblonde    & almostblack
let s:TI = [ 222 , 238 ] " dirtyblonde    & darkgravel
let s:TS = [ 232 , 154 ] " blackestgravel & lime

let s:PA = [ 222 ]                   " dirtyblonde
let s:RE = [ 211 ]                   " dress

let s:IA = [ s:N3[1] , s:N2[1] , '' ]

let s:p = {'normal': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'tabline': {}}

" normal mode
let s:p.normal.left = [
			\ [ s:N1[0], s:N1[1] ],
			\ [ s:N2[0], s:N2[1] ],
			\ [ s:N3[0], s:N3[1] ],
			\ ]
let s:p.normal.middle = [
			\ [ s:N3[0], s:N3[1] ],
			\ ]
let s:p.normal.right = copy(s:p.normal.left)

" insert mode
let s:p.insert.left = [
			\ [ s:I1[0], s:I1[1] ],
			\ [ s:I2[0], s:I2[1] ],
			\ [ s:I3[0], s:I3[1] ],
			\ ]
let s:p.insert.middle = [
			\ [ s:I3[0], s:I3[1] ],
			\ ]
let s:p.insert.right = copy(s:p.insert.left)

" replace mode
let s:p.replace.left = [
			\ [ s:I1[0], s:RE[0] ],
			\ [ s:I2[0], s:I2[1] ],
			\ [ s:I3[0], s:I3[1] ],
			\ ]

" visual mode
let s:p.visual.left = [
			\ [ s:V1[0], s:V1[1] ],
			\ [ s:V2[0], s:V2[1] ],
			\ [ s:V3[0], s:V3[1] ],
			\ ]
let s:p.visual.middle = [
			\ [ s:V3[0], s:V3[1] ],
			\ ]
let s:p.visual.right = copy(s:p.visual.left)

" tabline
let s:p.tabline.right = [
			\ [ s:T1[0], s:T1[1] ],
			\ [ s:T2[0], s:T2[1] ],
			\ ]
let s:p.tabline.middle = [
			\ [ s:T2[0], s:T2[1] ],
			\ ]
let s:p.tabline.left = [
			\ [ s:TI[0], s:TI[1] ],
			\ ]
let s:p.tabline.tabsel = [
			\ [ s:TS[0], s:TS[1] ],
			\ ]

" inactive window
let s:p.inactive.left = [
			\ [ s:IA[0], s:IA[1] ],
			\ [ s:IA[0], s:IA[1] ],
			\ [ s:IA[0], s:IA[1] ],
			\ ]
let s:p.inactive.middle = copy(s:p.inactive.left)
let s:p.inactive.right = copy(s:p.inactive.left)

" extra bits
let s:p.normal.error = [ [ 'gray9', 'brightestred' ] ]
let s:p.normal.warning = [ [ 'gray1', 'yellow' ] ]

let g:lightline#colorscheme#badwolf#palette = lightline#colorscheme#fill(s:p)

"let g:lightline#colorscheme#badwolf#palette = s:p
