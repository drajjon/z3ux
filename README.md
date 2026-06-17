# Z3UX

See project Wiki: https://github.com/drajjon/z3ux/wiki

Z3UX is published under a ["CC BY-NC 4.0"](https://creativecommons.org/licenses/by-nc/4.0/) license by Alexis Janson (aka "drajjon") - see [LICENSE.md](LICENSE.md) for details.

Organized C64-PETSCII and JPETSCII tilesets pulled from playscii - https://heptapod.host/jp-lebreton/playscii


## CURRENT TODO [probably out of date!]
- "console" output text (unit test status, "undead yarns")


diagonal / analog movement - by pixel, by cell
- ensure first tap always moves 1 cell before settling into rhythm, without extra taps being faster than holding or tap+hold
- unit tests needed for all of these [once it "feels right"]


possible yarn event behaviors [depending on need]
- locked
- auto-locking (don't interrupt)
- queueing / stacking / dropping

Should new_Yarn own adding itself to YarnBoss?
do we want to track "idle" threads in a separate pool? (feels FUTURE to me)

## FUTURE TODO
- top-level log handler?
- top-level Lua error(...) handler
    - assert.lua throws error tables see `telescope.lua`
      `error({format_message(message, ...), debug.traceback()})`
    - should I standardize on error tables
    - watch for errors in Yarns / coroutines