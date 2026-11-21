# E2E Test Framework Port

## Goal

Port the step-driven UI/e2e test framework from ball-game into love-exemplar so that any future Love2D game built from this template can inherit a working headless e2e harness without reimplementing it from scratch.

## Affected files

**New:**
- `lua/headless/ui_runner.lua` — step-driven e2e test runner
- `lua/core/ui.lua` — rect helpers (`find`, `centre`, `overlaps`, `hit`, `element_at`)
- `tests/ui/` — directory for e2e specs (currently empty; just establishes the convention)
- `docs/testing.md` — testing guide (adapted from ball-game, game-specific sections stripped)

**Modified:**
- `lua/headless/stubs.lua` — add text recording (`print`/`printf`) and virtual mouse cursor
- `lua/headless/runner.lua` — discover `tests/ui/` and run UIRunner after unit tests
- `lua/core/scene_manager.lua` — add `is_idle()`, `mouse_moved()`, `mouse_pressed()`, `mouse_released()`, `key_pressed()`

## What changes

### lua/core/ui.lua (new)
Thin rect-utility module with five functions:
- `UI.hit(rect, x, y)` — half-open point test
- `UI.element_at(elements, x, y)` — first element containing the point, or nil
- `UI.find(elements, id)` — linear scan by id
- `UI.centre(rect)` — returns `x + w/2, y + h/2` rounded to whole pixels
- `UI.overlaps(a, b)` — positive-area AABB intersection check

### lua/headless/stubs.lua
Two additions:
1. Text recording: `love.graphics.print` and `printf` now record to an internal log instead of calling noop. Exposes `Stubs.drawn_text()` and `Stubs.clear_text()`.
2. Virtual cursor: `love.mouse.getX/Y/getPosition` return a settable pair. Exposes `Stubs.set_mouse(x, y)`.

### lua/headless/runner.lua
After running unit tests, also discovers `tests/ui/*.lua` via `love.filesystem.getDirectoryItems`, hands each file to `UIRunner.run_file`, and accumulates pass/fail counts into the final tally.

### lua/core/scene_manager.lua
Five new methods, all delegating to `self.current` if it exists:
- `is_idle()` — returns `self._fade_state == "idle"`
- `mouse_moved(x, y)`
- `mouse_pressed(x, y, b)`
- `mouse_released(x, y, b)`
- `key_pressed(key)`

Scenes opt into UI testing by implementing `ui_elements()` (returns a list of `{id, label, kind, rect, enabled, selected}`). `assert_matrix` and `assert_tile` require `scene:ui_matrix()` and `scene:ui_tile(x, y)` respectively; they fail gracefully if the scene doesn't implement them.

### lua/headless/ui_runner.lua (new)
Direct port of ball-game's `ui_runner.lua` with two changes:
1. All `lua/game/progress` and `lua/game/puzzle_loader` setup (the `given` block) is removed — this was ball-game-specific. Callers pass `opts.setup(sm)` for any game-specific initialization before the first frame.
2. The default `make_scene` (ball-game's start_scene) is removed; `opts.make_scene(sm)` is required.

The spec format is otherwise identical to ball-game:
```lua
return {
    name  = "my spec",
    steps = {
        { press = "return" },
        { assert_text = "Hello" },
        { click_button = "Start" },
    },
}
```

## What stays the same

- `lua/headless/input.lua` — unchanged (identical to ball-game's already)
- All existing unit tests in `tests/` — unaffected
- `main.lua` headless dispatch — unchanged
- The spec file format, all step types, and all assertion types from ball-game carry over verbatim

### docs/testing.md (new)
Adapted from ball-game's `docs/testing.md`. Keeps: unit vs UI overview, running tests, step vocabulary, invariants, reading failures, adding `ui_elements()` to a scene, writing unit tests. Strips: `given.solved`/`given.cutscenes_unseen` (Progress-specific), ball-game element-id tables, ball-game-specific example specs. Adds: a note that `opts.setup(sm)` is the hook for game-specific initialization before the first frame.

## Open questions

None — the scope is a clean port with the game-specific layer stripped out.
