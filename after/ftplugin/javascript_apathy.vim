let b:node_modules = finddir('node_modules', fnamemodify(resolve(apathy#Real(@%)), ':h').';', -1)
if empty(b:node_modules)
  unlet b:node_modules
  finish
endif
call map(b:node_modules, 'fnamemodify(v:val, ":p:s?[\\/]$??")')

call apathy#Prepend('path', b:node_modules, apathy#EnvSplit($NODE_PATH))
call apathy#Prepend('suffixesadd', '.coffee,.ts,.tsx,.js,.mjs,.jsx,.json,.node')
call apathy#Append('suffixesadd', '/package.json')
setlocal include=\\%(\\<require\\s*(\\s*\\\|\\<import\\>[^;\"']*\\)[\"']\\zs[^\"']*
setlocal includeexpr=JavascriptNodeFind(v:fname,@%)

call apathy#Undo()

function! JavascriptNodeFind(target, current) abort
  let target = substitute(a:target, '^\~[^/]\@=', '', '')
  if target =~# '^\.\.\=/'
    let target = simplify(fnamemodify(resolve(a:current), ':p:h') . '/' . target)
  endif
  let found = findfile(target)
  if found =~# '[\/]package\.json$' && target !~# '[\/]package\.json$'
    try
      let package = json_decode(join(readfile(found)))
      let target .= '/' . substitute(get(package, 'main', 'index'), '\.js$', '', '')
    catch
    endtry
  endif
  return target
endfunction

" adapted from https://github.com/romainl/ctags-patterns-for-javascript
let &l:define = '\v' . (empty(&l:define) ? '' : '|')

" classes
let &l:define .= '^\s*var\s+\ze[A-Z]\i+\s*\=\s*function|' .
                  \ '^\s*let\s+\ze[A-Z]\i+\s*\=\s*function|' .
                  \ '^\s*const\s+\ze[A-Z]\i+\s*\=\s*function|' .
                  \ '^\s*class\s+\ze\i+|'

" methods
let &l:define .= '^\s*this\.\ze\i+\s*\=.*\{$|' .
      \ '^\s*\ze\i+\s*[:=]\s*\(*function\s*\(|' .
      \ '^\s*\ze\i+\s*\=\s.+\=\>|' .
      \ '^\s*static\s+\ze\i+\s*\(|' .
      \ '^\s*\ze\i+\(.*\)\s*\{|'

" generator functions
let &l:define .= '^\s*function\s*\*\s*\(\ze\i+\)|' .
      \ '^\s*var\s+\ze[a-z]\i+\s*\=\s*function\(\s*\*\)|' .
      \ '^\s*let\s+\ze[a-z]\i+\s*\=\s*function\(\s*\*\)|' .
      \ '^\s*const\s+\ze[a-z]\i+\s*\=\s*function\(\s*\*\)|' .
      \ '^\s*\(\*\s\)\ze\i+\s*.*\s*\{|'

" free-form functions
let &l:define .= '^\s*function\s*\i+[[:space:](]|' .
                  \ '^\s*\(function\s*\i+[[:space:](]|' .
                  \ '^\s*var\s+\ze[a-z]\i+\s*\=\s*function[^\*][^\*]|' .
                  \ '^\s*let\s+\ze[a-z]\i+\s*\=\s*function[^\*][^\*]|' .
                  \ '^\s*const\s+\ze[a-z]\i+\s*\=\s*function[^\*][^\*]|' .
                  \ '^\s*var\s+\ze[a-z]\i+\s*\=\s*\([^\*]|' .
                  \ '^\s*let\s+\ze[a-z]\i+\s*\=\s*\([^\*]|' .
                  \ '^\s*const\s+\ze[a-z]\i+\s*\=\s*\([^\*]'
