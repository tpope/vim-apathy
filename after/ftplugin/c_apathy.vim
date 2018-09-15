function! s:CPreProcIncludes(cmd) abort
  let paths = []
  let active = 0
  for line in executable('cpp') ? split(system(a:cmd), "\n") : []
    if line =~# '^#include '
      let active = 1
    elseif line =~# '^\S'
      let active = 0
    elseif active
      call add(paths, matchstr(line, '\S\+'))
    endif
  endfor
  return paths
endfunction

if &filetype ==# 'cpp' 
  if !exists('g:cpp_path')
    let g:cpp_path = ['.'] + s:CPreProcIncludes('cpp -v -x c++')
  endif
  call apathy#Prepend('path', g:cpp_path)
else
  if !exists('g:c_path')
    let g:c_path = ['.'] + s:CPreProcIncludes('cpp -v -x c')
  endif
  call apathy#Prepend('path', g:c_path)
endif

setlocal include&
setlocal includeexpr&
setlocal define&

call apathy#Undo()
