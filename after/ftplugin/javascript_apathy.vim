call apathy#Prepend('suffixesadd', '.coffee,.ts,.tsx,.js,.mjs,.jsx,.json,.node')
call apathy#Append('suffixesadd', '/package.json')
setlocal include=\\%(\\<require\\s*(\\s*\\\|\\<import\\>[^;\"']*\\)[\"']\\zs[^\"']*
setlocal includeexpr=JavascriptNodeFind(v:fname,@%)

call apathy#Undo()

let b:node_modules = finddir('node_modules', fnamemodify(resolve(apathy#Real(@%)), ':h').';', -1)

if empty(b:node_modules)
  unlet b:node_modules
  finish
endif

call map(b:node_modules, 'fnamemodify(v:val, ":p:s?[\\/]$??")')

call apathy#Prepend('path', b:node_modules, apathy#EnvSplit($NODE_PATH))

if executable('npm')
  call apathy#Append('path', substitute(system('npm root -g'), '\v\n+$', '', ''))
endif

let b:modules_path = &path

" Force vim to use our includeexpr so we have a chance to parse the
" package.json and extract main
setlocal path=''

function! JavascriptNodeFind(target, current) abort
  let target = substitute(a:target, '^\~[^/]\@=', '', '')
  if target =~# '^\.\.\=/'
    let target = simplify(fnamemodify(resolve(a:current), ':p:h') . '/' . target)
  endif
  let found = findfile(target, b:modules_path)
  if found =~# '[\/]package\.json$' && target !~# '[\/]package\.json$'
    try
      let package = json_decode(join(readfile(found)))
      let target = fnamemodify(found, ':h') . '/' . substitute(get(package, 'main', 'index'), '\.js$', '', '')
    catch
    endtry
  endif
  return target
endfunction
