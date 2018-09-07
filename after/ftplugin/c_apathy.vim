if !exists('g:c_path')
  let g:c_path = ['.']
  let s:active = 0
  for s:line in executable('cpp') ? split(system('cpp -v'), "\n") : []
    if s:line =~# '^#include '
      let s:active = 1
    elseif s:line =~# '^\S'
      let s:active = 0
    elseif s:active
      call add(g:c_path, matchstr(s:line, '\S\+'))
    endif
  endfor
  unlet! s:active s:line
endif

call apathy#Prepend('path', g:c_path)
setlocal include&
setlocal includeexpr&
setlocal define&

call apathy#Undo()
