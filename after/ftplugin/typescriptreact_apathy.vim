" bulk borrowed from https://gist.github.com/romainl/a50b49408308c45cc2f9f877dfe4df0c#file-typescript-vim

let b:node_modules = finddir('node_modules', fnamemodify(resolve(apathy#Real(@%)), ':h').';', -1)
if empty(b:node_modules)
  unlet b:node_modules
  finish
endif
call map(b:node_modules, 'fnamemodify(v:val, ":p:s?[\\/]$??")')

if len(b:node_modules)
  let b:ts_node_modules = map(b:node_modules, { idx, val -> substitute(fnamemodify(val, ':p'), '/$', '', '')})
endif

let tsconfig_file = findfile('tsconfig.json', '.;')
if len(tsconfig_file)
  let tsconfig_data = json_decode(join(readfile(tsconfig_file)))

  let paths = values(map(tsconfig_data.compilerOptions.paths, {key, val -> [
        \ glob2regpat(key),
        \ substitute(val[0], '\/\*$', '', '')]
        \ }))

  for path in paths
    let path[1] = finddir(path[1], '.;')
  endfor

  let b:ts_config_paths = paths

  unlet tsconfig_file
  unlet tsconfig_data
  unlet paths
endif

call apathy#Prepend('path', b:node_modules, apathy#EnvSplit($NODE_PATH))
setlocal include=^\\s*[^\/]\\+\\(from\\\|require(\\)\\s*['\"\.]
let &l:define  = '^\s*\('
      \ . '\(export\s\)*\(default\s\)*\(var\|const\|let\|function\|class\|interface\)\s'
      \ . '\|\(public\|private\|protected\|readonly\|static\)\s'
      \ . '\|\(get\s\|set\s\)'
      \ . '\|\(export\sdefault\s\|abstract\sclass\s\)'
      \ . '\|\(async\s\)'
      \ . '\|\(\ze\i\+([^)]*).*{$\)'
      \ . '\)'

setlocal includeexpr=TypeScriptIncludeExpression(v:fname,0)

setlocal suffixesadd+=.ts,.tsx,.d.ts,.js,.jsx
setlocal isfname+=@-@

call apathy#Undo()

if !exists("*TypeScriptIncludeExpression")
  function TypeScriptIncludeExpression(fname, gf) abort
    " BUILT-IN NODE MODULES
    " =====================
    " they aren't natively accessible but we can use @types
    if index([
          \ 'assert', 'async_hooks',
          \ 'base', 'buffer',
          \ 'child_process', 'cluster', 'console', 'constants', 'crypto',
          \ 'dgram', 'dns', 'domain',
          \ 'events',
          \ 'fs',
          \ 'globals',
          \ 'http', 'http2', 'https',
          \ 'inspector',
          \ 'net',
          \ 'os',
          \ 'path', 'perf_hooks', 'process', 'punycode',
          \ 'querystring',
          \ 'readline', 'repl',
          \ 'stream', 'string_decoder',
          \ 'timers', 'tls', 'trace_events', 'tty',
          \ 'url', 'util',
          \ 'v8', 'vm',
          \ 'worker_threads',
          \ 'zlib' ], a:fname) != -1

      let found_definition = b:ts_node_modules[0] . '/@types/node/' . a:fname . '.d.ts'

      if filereadable(found_definition)
        return found_definition
      endif

      return 0
    endif

    " LOCAL IMPORTS
    " =============
    " they are everywhere so we must get them right
    if a:fname =~ '^\.'
      " ./
      if a:fname =~ '^\./$'
        return 'index.ts'
      endif

      " ../
      if a:fname =~ '\.\./$'
        return a:fname . 'index.ts'
      endif

      " ./foo
      " ./foo/bar
      " ../foo
      " ../foo/bar
      " simplify module name to find it more easily
      let module_name = substitute(a:fname, '^\W*', '', '')

      " first, look for the module name only
      " (findfile() uses 'suffixesadd')
      let found_plain = findfile(module_name, '.;')
      if len(found_plain)
        return found_plain
      endif

      " second, look for an index.ts file
      let found_index = findfile(module_name . '/index.ts', '.;')
      if len(found_index)
        return found_index
      endif

      " give up
      if filereadable(a:fname)
        return a:fname
      endif

      return 0
    endif

    " ALIASED IMPORTS
    " ===============
    " https://code.visualstudio.com/docs/languages/jsconfig
    " https://webpack.js.org/configuration/resolve/#resolve-alias
    if exists('b:ts_config_paths')
      for path in b:ts_config_paths
        if a:fname =~ path[0]
          let base_name = fnamemodify(substitute(path[1], '\^', '', '') . '/' . substitute(a:fname, path[0], '', ''), ':p')

          if isdirectory(base_name)
            return findfile(base_name . 'index')
          endif

          return findfile(base_name)
        endif
      endfor
    endif

    " this is where we stop for include-search/definition-search
    if !a:gf
      if filereadable(a:fname)
        return a:fname
      endif

      return 0
    endif

    " NODE IMPORTS
    " ============
    " give up if there's no node_modules
    if !len(get(b:, 'ts_node_modules', []))
      if filereadable(a:fname)
        return a:fname
      endif

      return 0
    endif

    " split the filename in meaningful parts:
    " - a package name, used to search for the package in node_modules/
    " - a subpath if applicable, used to reach the right module
    "
    " example:
    " import bar from 'coolcat/foo/bar';
    " - package_name = coolcat
    " - sub_path     = foo/bar
    "
    " special case:
    " import something from '@scope/something/else';
    " - package_name = @scope/something
    " - sub_path     = else
    let parts = split(a:fname, '/')

    if parts[0] =~ '^@'
      let package_name = join(parts[0:1], '/')
      let sub_path = join(parts[2:-1], '/')
    else
      let package_name = parts[0]
      let sub_path = join(parts[1:-1], '/')
    endif

    " find the package.json for that package
    let package_json = b:ts_node_modules[-1] . '/' . package_name . '/package.json'

    " give up if there's no package.json
    if !filereadable(package_json)
      if filereadable(a:fname)
        return a:fname
      endif

      return 0
    endif

    if len(sub_path) == 0
      " grab data from the package.json
      let package = json_decode(join(readfile(package_json)))

      " build path from 'main' key
      return fnamemodify(package_json, ':p:h') . "/" . substitute(get(package, "main", "index.js"), '^\.\{1,2}\/', '', '')
    else
      " build the path to the module
      let common_path = fnamemodify(package_json, ':p:h') . '/' . sub_path

      " first, try with .js
      let found_dot_js = glob(common_path . '.js', 1)
      if len(found_dot_js)
        return found_dot_js
      endif

      " second, try with /index.js
      let found_index_js = glob(common_path . '/index.js', 1)
      if len(found_index_js)
        return found_index_js
      endif

      " give up
      if filereadable(a:fname)
        return a:fname
      endif

      return 0
    endif

    " give up
    if filereadable(a:fname)
      return a:fname
    endif

    return 0
  endfunction
endif

