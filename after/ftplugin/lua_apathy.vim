function! s:matchfilter(list, pat) abort
  return filter(map(copy(a:list), 'matchstr(v:val, '.string(a:pat).')'), 'len(v:val)')
endfunction

if !exists('g:lua_path')
  let g:lua_path = split(system('lua -e "print(package.path)"')[0:-2], ';')
  if v:shell_error || empty(g:lua_path)
    let g:lua_path = ['./?.lua', './?/init.lua']
  endif
endif

call apathy#Prepend('path',        s:matchfilter(g:lua_path, '^[^?]*[^?\/]'))
call apathy#Prepend('suffixesadd', s:matchfilter(g:lua_path, '?\zs[^?]*$'))
setlocal include=\\<require\\s*(\\=\\s*[\"']
setlocal includeexpr=LuaIncludeExpr(v:fname)

call apathy#Undo()

function! LuaIncludeExpr(fname) abort
  if a:fname =~# '/' || a:fname =~# '\.lua$'
    return a:fname
  endif
  let fname = tr(a:fname, '.', '/')
  let file = fname
  while file !=# '.'
    for suffix in split(&l:suffixesadd, ',')
      let path = findfile(file . suffix)
      if !empty(path)
        return file . suffix
      endif
    endfor
    let file = fnamemodify(file, ':h')
  endwhile
  return fname
endfunction
