function! s:CPreProcIncludes(cmd) abort
  let l:paths = []
  let l:active = 0
  for l:line in executable('cpp') ? split(system(a:cmd), "\n") : []
    if l:line =~# '^#include '
      let l:active = 1
    elseif l:line =~# '^\S'
      let l:active = 0
    elseif l:active
      call add(l:paths, matchstr(l:line, '\S\+'))
    endif
  endfor
  return l:paths
endfunction

if &filetype ==# 'cpp' 
  if !exists('g:cpp_path')
    let g:cpp_path = ['.']
    let g:cpp_path += s:CPreProcIncludes('cpp -v -x c++')
  endif
  call apathy#Prepend('path', g:cpp_path)
else
  if !exists('g:c_path')
    let g:c_path = ['.']
    let g:c_path += s:CPreProcIncludes('cpp -v -x c')
  endif
  call apathy#Prepend('path', g:c_path)
endif

setlocal include&
setlocal includeexpr&
setlocal define&

call apathy#Undo()
