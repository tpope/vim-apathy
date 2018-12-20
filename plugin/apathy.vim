" Location: plugin/apathy.vim
" Author: Tim Pope <http://tpo.pe/>

if exists('g:loaded_apathy')
  finish
endif
let g:loaded_apathy = 1

if &g:path =~# '\v^\.,/%(usr|emx)/include,,$'
  setglobal path=.,,
endif
setglobal include=
setglobal includeexpr=
setglobal define=

setglobal isfname+=@-@
