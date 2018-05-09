call apathy#Prepend('path', "/usr/share/go/src/runtime")
call apathy#Prepend('path', map(apathy#Split(
      \ len($GOPATH) ? apathy#EnvSplit($GOPATH) : expand('~/go')),
      \ 'v:val . "/src"'))
setlocal suffixesadd=.go,/
setlocal include=^\\t\\%(\\w\\+\\s\\+\\)\\=\"\\zs[^\"]*\\ze\"$

call apathy#Undo()
