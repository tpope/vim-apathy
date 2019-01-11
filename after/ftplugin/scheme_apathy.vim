if !exists('g:scheme_load_path') && executable('guile')
  let g:scheme_load_path = split(system('guile -c '.shellescape('(display (string-join %load-path "\n"))')), "\n")
  if v:shell_error
    let g:scheme_load_path = []
  endif
elseif !exists('g:scheme_load_path')
  let g:scheme_load_path = []
endif

call apathy#Prepend('path', g:scheme_load_path)
call apathy#Prepend('suffixesadd', '.scm')
setlocal include=[(:]use-modules\\=\\s\\+(\\+\\zs[^)]*
setlocal includeexpr=tr(v:fname,'\ ','/')
setlocal define=(define\\S*\\s\\+(\\=

call apathy#Undo()
