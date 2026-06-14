# Z3UX

See project Wiki: https://github.com/drajjon/z3ux/wiki

Z3UX is published under a ["CC BY-NC 4.0"](https://creativecommons.org/licenses/by-nc/4.0/) license by Alexis Janson (aka "drajjon") - see [LICENSE.md](LICENSE.md) for details.

## FUTURE TODO
- top-level log handler?
- top-level Lua error(...) handler
    - assert.lua throws error tables see `telescope.lua`
      `error({format_message(message, ...), debug.traceback()})`
    - should I standardize on error tables
    - watch for errors in Yarns / coroutines