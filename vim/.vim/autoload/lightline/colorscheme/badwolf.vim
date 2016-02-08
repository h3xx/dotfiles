let s:N1 = [ '#141413' , '#aeee00' , 232 , 154 ] " blackestgravel & lime
let s:N2 = [ '#f4cf86' , '#45413b' , 222 , 238 ] " dirtyblonde    & deepgravel
let s:N3 = [ '#8cffba' , '#242321' , 121 , 235 ] " saltwatertaffy & darkgravel
let s:N4 = [ '#666462' , 241 ]                   " mediumgravel

let s:I1 = [ '#141413' , '#0a9dff' , 232 , 39  ] " blackestgravel & tardis
let s:I2 = [ '#f4cf86' , '#005fff' , 222 , 27  ] " dirtyblonde    & facebook
let s:I3 = [ '#0a9dff' , '#242321' , 39  , 235 ] " tardis         & darkgravel

let s:V1 = [ '#141413' , '#ffa724' , 232 , 214 ] " blackestgravel & orange
let s:V2 = [ '#000000' , '#fade3e' , 16  , 221 ] " coal           & dalespale
let s:V3 = [ '#000000' , '#b88853' , 16  , 137 ] " coal           & toffee
let s:V4 = [ '#c7915b' , 173 ]                   " coffee

let s:T1 = [ '#141413' , '#ffa724' , 232 , 214 ] " blackestgravel & darkorange
let s:T2 = [ '#f4cf86' , 'grey10'  , 222 , 233 ] " dirtyblonde    & almostblack
let s:TI = [ '#f4cf86' , '#242321' , 222 , 235 ] " dirtyblonde    & darkgravel
let s:TS = [ '#141413' , '#aeee00' , 232 , 154 ] " blackestgravel & lime

let s:PA = [ '#f4cf86' , 222 ]                   " dirtyblonde
let s:RE = [ '#ff9eb8' , 211 ]                   " dress

let s:IA = [ s:N3[1] , s:N2[1] , s:N3[3] , s:N2[3] , '' ]

let s:p = {'normal': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'tabline': {}}

" normal mode
let s:p.normal.left = [
			\ [ s:N1[2], s:N1[3] ],
			\ [ s:N2[2], s:N2[3] ],
			\ [ s:N3[2], s:N3[3] ],
			\ ]
let s:p.normal.middle = [
			\ [ s:N3[2], s:N3[3] ],
			\ ]
let s:p.normal.right = copy(s:p.normal.left)

" insert mode
let s:p.insert.left = [
			\ [ s:I1[2], s:I1[3] ],
			\ [ s:I2[2], s:I2[3] ],
			\ [ s:I3[2], s:I3[3] ],
			\ ]
let s:p.insert.middle = [
			\ [ s:I3[2], s:I3[3] ],
			\ ]
let s:p.insert.right = copy(s:p.insert.left)

" replace mode
let s:p.replace.left = [
			\ [ s:I1[2], s:RE[1] ],
			\ [ s:I2[2], s:I2[3] ],
			\ [ s:I3[2], s:I3[3] ],
			\ ]

" visual mode
let s:p.visual.left = [
			\ [ s:V1[2], s:V1[3] ],
			\ [ s:V2[2], s:V2[3] ],
			\ [ s:V3[2], s:V3[3] ],
			\ ]
let s:p.visual.middle = [
			\ [ s:V3[2], s:V3[3] ],
			\ ]
let s:p.visual.right = copy(s:p.visual.left)

" tabline
let s:p.tabline.right = [
			\ [ s:T1[2], s:T1[3] ],
			\ [ s:T2[2], s:T2[3] ],
			\ ]
let s:p.tabline.middle = [
			\ [ s:T2[2], s:T2[3] ],
			\ ]
let s:p.tabline.left = [
			\ [ s:TI[2], s:TI[3] ],
			\ ]
let s:p.tabline.tabsel = [
			\ [ s:TS[2], s:TS[3] ],
			\ ]

" inactive window
let s:p.inactive.left = [
			\ [ s:IA[2], s:IA[3] ],
			\ [ s:IA[2], s:IA[3] ],
			\ [ s:IA[2], s:IA[3] ],
			\ ]
let s:p.inactive.middle = copy(s:p.inactive.left)
let s:p.inactive.right = copy(s:p.inactive.left)

" extra bits
let s:p.normal.error = [ [ 'gray9', 'brightestred' ] ]
let s:p.normal.warning = [ [ 'gray1', 'yellow' ] ]

let g:lightline#colorscheme#badwolf#palette = lightline#colorscheme#fill(s:p)

"let g:lightline#colorscheme#badwolf#palette = s:p
