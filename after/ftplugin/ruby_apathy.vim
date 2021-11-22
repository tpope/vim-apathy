" Remove "." and "" from the otherwise accurate 'path' from ftplugin/ruby.vim
if &l:path =~# ',\.,,$'
  let &l:path = substitute(&l:path, ',\.,,$', '', 'g')
endif
