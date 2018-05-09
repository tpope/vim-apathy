if !exists('g:python_path')
  let g:python_path = split(system(get(g:, 'python_executable', 'python') . ' -c "import sys; print(''\n''.join(sys.path))"')[0:-2], "\n", 1)
  if v:shell_error
    let g:python_path = []
  endif
end

call apathy#Prepend('path', g:python_path)
call apathy#Prepend('suffixesadd', '.py,/__init__.py')

call apathy#Undo()
