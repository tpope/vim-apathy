call apathy#Prepend('path', apathy#EnvSplit($PATH))
call apathy#Prepend('suffixesadd', apathy#EnvSplit($PATHEXT))
setlocal include=^\\s*call

call apathy#Undo()
