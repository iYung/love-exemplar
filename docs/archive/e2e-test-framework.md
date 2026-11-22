# E2E Test Framework Checklist

- [x] Task 1 — `lua/core/ui.lua` (new) — Create the rect-utility module with `UI.hit(rect, x, y)`, `UI.element_at(elements, x, y)`, `UI.find(elements, id)`, `UI.centre(rect)`, `UI.overlaps(a, b)`. No game dependencies.

- [x] Task 2 — `lua/headless/stubs.lua` — Add text recording: `love.graphics.print` and `printf` now append their string to an internal log instead of calling noop. Expose `Stubs.drawn_text()` (returns the log array) and `Stubs.clear_text()` (resets it). Add virtual cursor: `love.mouse.getX`, `getY`, `getPosition` return a settable pair; expose `Stubs.set_mouse(x, y)`. Also add `love.mouse.isDown` (returns false) and `love.graphics.getWidth`/`getHeight` (return 1280/720). Port directly from ball-game's stubs, keeping the existing stubs intact.

- [x] Task 3 — `lua/core/scene_manager.lua` — Add five new methods: `is_idle()` (returns `self._fade_state == "idle"`), `mouse_moved(x, y)`, `mouse_pressed(x, y, b)`, `mouse_released(x, y, b)`, `key_pressed(key)` — each delegates to `self.current` if it exists and the scene implements the method.

- [x] Task 4 — `lua/headless/ui_runner.lua` (new) — Port ball-game's `lua/headless/ui_runner.lua` with these changes: (a) remove all `lua/game/progress`, `lua/game/puzzle_loader`, and `start_scene` references from `run_spec`; (b) replace the hardcoded `given`/Progress setup with an optional `opts.setup(sm)` callback that runs before the first frame; (c) `opts.make_scene(sm)` is required (no default). All step handlers, invariant checks, serialiser, and report/run_file/run_spec API are verbatim from ball-game.

- [x] Task 5 — `lua/headless/runner.lua` — After the existing unit-test loop, discover `tests/ui/*.lua` via `love.filesystem.getDirectoryItems("tests/ui")`, pass each file to `UIRunner.run_file`, accumulate pass/fail into the shared counters, and include UI spec counts in the final total. Single-file dispatch: when the given path starts with `tests/ui/`, route it through UIRunner instead of `dofile`. Port directly from ball-game's runner.

- [x] Task 6 — `docs/testing.md` (new) — Write the testing guide adapted from ball-game's `docs/testing.md`. Keep: unit vs UI overview, running-tests section, step vocabulary table, invariants section, reading-failures table, adding `ui_elements()` section, writing-unit-tests section. Strip: `given.solved`/`given.cutscenes_unseen`, ball-game scene-element tables, ball-game-specific example specs. Add: a note that `opts.setup(sm)` is the hook for game-specific initialization. Update the spec format example to omit `given`.
