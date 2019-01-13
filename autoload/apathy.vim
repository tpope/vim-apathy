" Location: autoload/apathy.vim
" Author: Tim Pope <http://tpo.pe/>

if exists('g:autoloaded_apathy')
  finish
endif
let g:autoloaded_apathy = 1

function! apathy#Uniq(list) abort
  let i = 0
  let seen = {}
  while i < len(a:list)
    let str = string(a:list[i])
    if has_key(seen, str)
      call remove(a:list, i)
    else
      let seen[str] = 1
      let i += 1
    endif
  endwhile
  return a:list
endfunction

function! apathy#Join(...) abort
  let val = []
  for arg in a:000
    if type(arg) == type([])
      call add(val, join(map(copy(arg), 'escape(v:val, ", ")'), ','))
    else
      call add(val, arg)
    endif
    unlet arg
  endfor
  let str = join(val, ',')
  return substitute(str, '\m,\@<!,$', ',,', '')
endfunction

function! apathy#Split(...) abort
  let val = []
  for arg in a:000
    if type(arg) == type([])
      call extend(val, arg)
    elseif !empty(arg)
      let split = split(arg, '\\\@<!\%(\\\\\)*\zs,')
      call map(split, 'substitute(v:val,''\\\([\\,]\)'',''\1'',"g")')
      call extend(val, split)
    endif
    unlet arg
  endfor
  return val
endfunction

function! apathy#Real(file) abort
  let pre = substitute(matchstr(a:file, '^\a\a\+\ze:'), '^.', '\u&', '')
  if empty(pre)
    return fnamemodify(a:file, ':p')
  elseif exists('*' . pre . 'Real')
    return {pre}Real(a:file)
  else
    return ''
  endif
endfunction

function! apathy#EnvSplit(val, ...) abort
  return len(a:val) ? split(a:val, has('win32') ? ';' : ':') : a:000
endfunction

function! apathy#Prepend(opt, ...) abort
  let orig = getbufvar('', '&'.a:opt)
  let val = apathy#Join(apathy#Uniq(call('apathy#Split', a:000 + [orig])))
  call setbufvar('', '&'.a:opt, val)
  return val
endfunction

function! apathy#Append(opt, ...) abort
  let orig = getbufvar('', '&'.a:opt)
  let val = apathy#Join(apathy#Uniq(call('apathy#Split', [orig] + a:000)))
  call setbufvar('', '&'.a:opt, val)
  return val
endfunction

function! apathy#Undo(...) abort
  let undo = 'setl pa= sua= inc= inex= def='
  if exists('b:undo_ftplugin')
    let b:undo_ftplugin .= '|' . undo
  else
    let b:undo_ftplugin = undo
  endif
endfunction
