function! s:CPreProcIncludes(exe, opts) abort
  let paths = []
  let active = 0
  for line in executable(a:exe) ? split(system(a:exe . ' ' . a:opts), "\n") : []
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
    let g:c_path_compiler = get(g:, 'c_path_compiler', executable('clang') ? 'clang' : 'gcc')
    let g:cpp_path = ['.'] + s:CPreProcIncludes(g:c_path_compiler, '-E -v -x c++ /dev/null')
  endif
  call apathy#Prepend('path', g:cpp_path)
else
  if !exists('g:c_path')
    let g:c_path_compiler = get(g:, 'c_path_compiler', executable('clang') ? 'clang' : 'gcc')
    let g:c_path = ['.'] + s:CPreProcIncludes(g:c_path_compiler, '-E -v -x c /dev/null')
  endif
  call apathy#Prepend('path', g:c_path)
endif

setlocal include=^\\s*#\\s*include\\s*[\"<]\\@=
setlocal includeexpr&
setlocal define&

call apathy#Undo()
