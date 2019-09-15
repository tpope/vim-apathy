# apathy.vim

Apathy sets the five path searching options — `'path'`, `'suffixesadd'`,
`'include'`, `'includeexpr'`, and `'define'` — for file types I don't care
about enough to bother with creating a proper plugin.

## Rationale

As you might have guessed from `/usr/include` being in the default, the
original purpose of the `'path'` option was to house the C preprocessor
include path.  This enabled Vim to parse a preprocessor declaration like
`#include <stdio.h>` and determine that the file being included was
`/usr/include/stdio.h`.  Several features are built-in on this groundwork:

* `gf`, `<C-W>f`, `<C-W>gf`: jump to the included file under the cursor.
* `:find`, `:sfind`, `:tabfind`: jump to the specified included file.
* `[i`: display the first line in the current file or an included file
  containing the keyword under the cursor.
* `]i`: like above, but start searching after the cursor.
* `:isearch`: like above, but give your own line range and search pattern.
* `[I`, `]I`, `:ilist`: like above, but display all matches.
* `[<C-I>`, `]<C-I>`, `<C-W>i`, `:ijump`, `:isplit`: like above, but jump to
  the match.
* `<C-X><C-I>`: complete keywords from included files.
* `[d`, `]d`, `:dsearch`, `[D`, `]D`, `:dlist`, `[<C-D>`, `]<C-D>`, `<C-W>d`,
  `:djump`, `:dsplit`, `<C-X><C-D>`: like their `i` equivalents, but for macro
  definitions.
* `:checkpath`: list missing included files.

I list these exhaustively to stress that included files aren't just a
potential use of `'path'`, they are the very purpose of `'path'`.  If you've
been using `'path'` to contain a list of commonly accessed directories or
something like `**/*`, you're precluding yourself from using 38 different
commands.  Oops!  (Try one of the many fuzzy finder plugins instead.)

While Vim is set up for C by default, it provides a few options to use these
features for other languages:

* `'include'` is a pattern for matching include declarations, defaulting to
  `^\s*#\s*include`.  A value for JavaScript imports might look like
  `\<require\|\<from`.
* `'includeexpr'` is a simple function for converting an include to a
  filename. In languages like Java, Lua, and Python, this could be used to
  change `foo.bar` into `foo/bar`.
* `'suffixesadd`' is a list of file extensions to try.  JavaScript might use
  something like `.js,.coffee`.
* `'define'` is a pattern for matching macro definitions, defaulting to
  `^\s*#\s*define`.  This doesn't serve much purpose for languages without a
  preprocessor, but sometimes it is helpful to make it match function and/or
  variable declarations.

These, along with `'path'`, make up the purview of Apathy.

## Supported file types

* [C/C++/Objective C][C preprocessor path]
* [Go][GOPATH]
* [JavaScript/CoffeeScript/TypeScript][Node.js module system]
* [Lua][Lua package path]
* [Python][Python system path]
* [Scheme][Guile load path]
* [Shell scripts][PATH]
* [XDG Desktop Entries][XDG Base Directory Specification]

Additionally, the C related defaults are stripped out of the global config, so
you don't have to worry about `/usr/include` tainting everything.

[C preprocessor path]: https://gcc.gnu.org/onlinedocs/cpp/Search-Path.html
[GOPATH]: https://github.com/golang/go/wiki/GOPATH
[Node.js module system]: https://nodejs.org/api/modules.html
[Lua package path]: http://lua-users.org/wiki/PackagePath
[Python system path]: https://docs.python.org/2/library/sys.html#sys.path
[Guile load path]: https://www.gnu.org/software/guile/manual/html_node/Load-Paths.html
[PATH]: https://en.wikipedia.org/wiki/PATH_(variable)
[XDG Base Directory Specification]: https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html

## Related plugins

* [vim-ruby][], [rails.vim][], [rake.vim][], [bundler.vim][], [rbenv.vim][],
  and [rvm.vim][] all work together to replicate Ruby's `$LOAD_PATH`.
  Notably, rails.vim's intelligent `gf` map is built on `'path'`.
* [vim-perl][] (included with Vim) uses Perl's `@INC`.
* [classpath.vim][] extracts the JVM class path from tools like Maven and
  Leiningen.
* [fireplace.vim][] mimics Vim's macro definition maps, and optionally
  synergizes with classpath.vim.
* [scriptease.vim][] brings support to VimL by using `'runtimepath'`.
* [projectionist.vim][] provides for project specific `'path'` modification.

[vim-ruby]: https://github.com/vim-ruby/vim-ruby
[rails.vim]: https://github.com/tpope/vim-rails
[rake.vim]: https://github.com/tpope/vim-rake
[bundler.vim]: https://github.com/tpope/vim-bundler
[rbenv.vim]: https://github.com/tpope/vim-rbenv
[rvm.vim]: https://github.com/tpope/vim-rvm
[vim-perl]: https://github.com/vim-perl/vim-perl
[classpath.vim]: https://github.com/tpope/vim-classpath
[fireplace.vim]: https://github.com/tpope/vim-fireplace
[scriptease.vim]: https://github.com/tpope/vim-scriptease
[projectionist.vim]: https://github.com/tpope/vim-projectionist

## Installation

Install using your favorite package manager, or use Vim's built-in package
support:

    mkdir -p ~/.vim/pack/tpope/start
    cd ~/.vim/pack/tpope/start
    git clone https://tpope.io/vim/apathy.git

## License

Copyright © Tim Pope.  Distributed under the same terms as Vim itself.
See `:help license`.
