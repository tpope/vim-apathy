if expand('%:p') =~# '/autostart/'
  let &l:path = apathy#Join(map(
        \ apathy#EnvSplit($XDG_CONFIG_HOME, expand('~/.config')) +
        \ apathy#EnvSplit($XDG_CONFIG_DIRS, '/etc/xdg'),
        \ 'v:val . "/autostart"'))
elseif expand('%:p') =~# '/applications/'
  let &l:path = apathy#Join(map(
        \ apathy#EnvSplit($XDG_DATA_HOME, expand('~/.local/share')) +
        \ apathy#EnvSplit($XDG_DATA_DIRS, '/usr/local/share', '/usr/share'),
        \ 'v:val . "/applications"'))
endif
setlocal suffixesadd=.desktop,.directory
setlocal define=^\\%([A-Za-z0-9-]\\+=\\)\\@=

call apathy#Undo()
