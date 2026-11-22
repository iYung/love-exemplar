# Testing guide

This project has two kinds of tests. Both run headlessly in one process with one command.

| Kind | Location | What it does |
|---|---|---|
| Unit tests | `tests/*.lua` | Plain Lua scripts that `assert`. They often call scene internals directly through `runner.setup` / `runner.tick` / `HeadlessInput` (`lua/headless/runner.lua`). |
| UI specs | `tests/ui/*.lua` | Declarative tables that drive the **real game like a player does**: key presses and clicks at on-screen positions, sent through `SceneManager`, with `update` and `draw` on every frame. Layout invariants are checked on every frame automatically. |

**Why UI specs exist.** Regressions can ship while every unit test passes. Unit tests tend to skip the input and layout layer: they call private scene methods, never send clicks, never hit-test, and never call `draw()`. Real bugs live in exactly that layer — a button placed off-screen, two elements overlapping so one swallows clicks meant for the other, a keyboard handler that fires when it shouldn't. Each feature can pass its own unit tests while silently breaking another. UI specs close that gap by driving the real game through the same path a player takes. Read the process rules below before shipping anything.

There is no third-party test framework (no busted, no luaunit). Both kinds run on the project's own harness in `lua/headless/`: `runner.lua` runs every `tests/test_*.lua`, then every spec in `tests/ui/`, and prints a single total.

### Which kind to write

| You are testing… | Write |
|---|---|
| Anything the player can click or press: a new button, key, screen or flow | A UI spec (required, see rule 1) |
| Pure logic: data structures, algorithms, game rules | A unit test |
| Logic with many edge cases behind a UI feature | Both: a spec for the path the player takes, unit tests for the edge cases |
| A specific layout bug you just fixed | A unit test that pins the exact rects, if you want a sharper failure message than the spec's invariant error |

### What these tests cannot catch

Both kinds run against stubbed LÖVE (`lua/headless/stubs.lua`), so neither one sees:

- **Real rendering.** Nothing is drawn. The font stub reports every string as 120px wide, so text that overflows its box, wrong colors and missing sprites all pass. Lay out with constants, not `font:getWidth`, and check visual changes by running the game.
- **Saves.** The `love.filesystem` stubs don't write anything, so the save file is never read or written.
- **The web build.** `web.yml` builds the web version and deploys a PR preview but never loads or plays it. Open the preview link on the PR.

For those, run the game (`love .`) or open the PR preview.

---

## Process rules (mandatory)

> **Testing rules for every feature**
> 1. Every new feature adds or extends a `tests/ui/` spec that drives the feature through real input (keys and clicks via the registry). Calling private scene methods does not count as UI coverage.
> 2. In the verification phase, **any edit to a pre-existing test or spec is flagged as a potential regression**, not accepted silently. The verifier must state why the old expectation was wrong. If the game broke the test, the fix goes back to Phase 3 against the game, not the test.
> 3. Every interactive element must appear in its scene's `ui_elements()`, and hit-testing must go through the registry. Elements that are not in the registry cannot be tested and count as a bug.
> 4. Specs assert what the player sees (drawn text, buttons, board state). They do not assert incidental facts such as exact counts or internal coordinates, unless that fact is the feature.

In practice:
- **Feature authors (Phase 3):** add a spec or extend one in `tests/ui/`. A new clickable thing also needs a `ui_elements()` entry (see [Adding `ui_elements()` to a scene](#adding-ui_elements-to-a-scene)).
- **Verifiers (Phase 4):** run `git diff master -- tests/` and look for changed lines in files that already existed, especially changed assertions. List each one in the verification report with the reason the old expectation was wrong. If the test was right and the game broke it, send the fix back to Phase 3.

---

## Running tests

```sh
love . --headless                              # all unit tests, then all UI specs
love . --headless tests/ui/my_spec.lua        # one UI spec file (every spec in it)
love . --headless tests/test_camera.lua       # one unit test file
```

- Any path that starts with `tests/ui/` runs as a spec file. Any other path runs as a unit test.
- You cannot run a single spec out of a multi-spec file by name. Put the spec in its own file temporarily, or comment out its siblings while you iterate (do not commit that).
- The exit code is 0 when everything passes and 1 otherwise. CI (`.github/workflows/ci.yml`) runs the bare `love . --headless`.
- On a machine without a display you may see `error: XDG_RUNTIME_DIR is invalid...`. It is harmless.
- `love . --visual <unit test>` is unchanged and applies to unit tests only.

### Output

```
PASS  tests/test_basics.lua
FAIL  tests/test_foo.lua — tests/test_foo.lua:12: assertion failed!
PASS  tests/ui/01_my_feature.lua :: my feature works
FAIL  tests/ui/02_other.lua :: other flow — step 7 {click_button = "Start"} — element 'menu:start' is disabled
FAIL  tests/ui/99_broken.lua — tests/ui/99_broken.lua:3: '}' expected near 'steps'
4/5 passed
```

- Each unit file and each **spec** counts once toward the total. A spec file that fails to load counts as one failure.
- A single-file run prints the per-spec lines and then a bare `PASS` or `FAIL`.

---

## Spec file format

A spec file returns **one spec** or a **list of specs**:

```lua
-- one spec
return {
    name  = "my feature works",
    steps = { ... },
}

-- several specs; each gets its own fresh SceneManager
return {
    { name = "first flow",  steps = { ... } },
    { name = "second flow", steps = { ... } },
}
```

| Field | Meaning |
|---|---|
| `name` | Shown in the report. Defaults to `spec <n>`. |
| `steps` | An array of steps. Each step is a table with **exactly one** key from the vocabulary below. |

A spec is Lua, so you may build `steps` with loops. The file must still evaluate to plain data.

**Every spec starts the same way:** a new `SceneManager` (1280x720) is created, `opts.make_scene(sm)` builds the initial scene, the virtual cursor goes to (0, 0), and one frame runs. Specs never depend on run order.

**Game-specific initialization.** Pass `opts.setup(sm)` to `UIRunner.run_spec` to run any setup before the first frame — resetting singletons, pre-populating state, etc. This is where game-specific concerns (progress, saves, flags) go. The base runner does not assume any game structure.

---

## Step vocabulary

A step has exactly one of these keys. Any other key fails with `unknown step key '<k>'`, and a step with two keys fails with `step must have exactly one key`.

A **selector** is either a label string (`"Run"`) or a table `{ id = "cmd:run" }`. `assert_button` also accepts `{ label = "Run", ... }`. A label matches any element kind. If a label matches more than one element, the step fails with `ambiguous label '<l>' (<n> matches)`. Use `id` in that case.

| Step | Meaning |
|---|---|
| `press = "<key>"` | `sm:key_pressed(key)`. Uses LÖVE key names: `"return"`, `"escape"`, `"space"`, `"backspace"`, `"up"`, `"down"`, `"left"`, `"right"`, `"r"`, ... |
| `click = {x, y}` / `right_click = {x, y}` | A raw click at logical coordinates. This is the escape hatch, for example to check that clicking a disabled button does nothing, or to click empty space. |
| `click_button = sel` / `right_click_button = sel` | Click the centre of the matching element. It fails if the element is missing or disabled. |
| `click_cell = {x, y [, part = "left" \| "centre" \| "right"]}` / `right_click_cell` | Click grid cell `cell:<x>,<y>`. `part` picks the -1 third (`x + w/6`), the centre (the default) or the +1 third (`x + 5w/6`) of a parameter cell. |
| `click_slot = {pusher = 1 or "A", slots = {...}, times = k}` / `right_click_slot` | Click each listed slot of a timeline `k` times (default 1). A slot outside the visible window fails. The runner **never auto-scrolls**. |
| `move_mouse = {x, y}` | Move the virtual cursor and fire `sm:mouse_moved`. |
| `hover_button = sel` | Move to the element's centre. Disabled elements are allowed. |
| `wait = n` | Run n frames. |
| `wait_until = { text = "...", matrix = {{...}}, max_frames = n }` | Run frames until all given conditions hold. `max_frames` defaults to 600. On timeout: `wait_until exceeded <n> frames`. It does **not** settle a fade first. |
| `assert_text = "..."` / `assert_no_text = "..."` | A plain substring match against every string drawn by `print`/`printf` in the most recent frame. |
| `assert_button = { <selector fields>, visible = bool, enabled = bool, selected = bool }` | `visible = false` asserts that the element is absent from the registry. Fields you leave out are not checked. A nil `selected` counts as false. |
| `assert_matrix = {{...}}` | The matrix the scene shows now. Rows of numbers, compared exactly. Requires `scene:ui_matrix()`. |
| `assert_tile = { x, y, kind = ..., op = ..., dir = ... }` | The tile at a grid cell. Leaving out `kind` asserts the cell is **empty**. Only the fields you give are compared. Requires `scene:ui_tile(x, y)`. |

`assert_matrix`, `wait_until.matrix` and `assert_tile` need a scene that implements `ui_matrix()` / `ui_tile()`. Otherwise they fail with `scene has no matrix` or `scene has no tiles`.

There are deliberately no assertions on scene names or internal status. Assert what the player can see.

---

## Frame loop, settling and input semantics

- **One frame** is `sm:update(1/60)`, then the text log is cleared, then `sm:draw()`, then the invariants are checked on `sm.current:ui_elements()`. Because `draw()` runs every frame, layout state set during draw exists exactly as it does in the real game.
- **Settle.** Before every input step and every assert step (but not `wait` or `wait_until`), the runner runs frames until the `SceneManager` fade is idle, for at most 60 frames. Otherwise the step fails with `fade did not finish`. A player waits out the fade, and so does the runner. Without the settle you would click on the scene being drawn while input already goes to the new scene.
- **After every input step**, exactly one frame runs so that the result is drawn before the next assert.
- **A click** at (x, y) with button b (1 = left, 2 = right) is `Stubs.set_mouse(x, y)`, `sm:mouse_moved(x, y)`, `sm:mouse_pressed(x, y, b)`, `sm:mouse_released(x, y, b)`. This is what LÖVE does. A move is `set_mouse` plus `mouse_moved`.
- Element centres are rounded to whole pixels (`UI.centre`).
- The runner never calls a scene handler or private method directly. Its only scene calls are the read-only `ui_elements()`, `ui_matrix()` and `ui_tile()`. Everything else goes through `SceneManager`.
- Headless stubs (`lua/headless/stubs.lua`): `love.graphics.getWidth/getHeight` return 1280/720. `love.mouse.getX/getY/getPosition` return the virtual cursor, and `isDown` returns false. Fonts are stubs that report a width of 120 for any text, so **never use `font:getWidth()` for layout**. Use constants.

---

## The UI element registry

Every scene that has clickable things implements `scene:ui_elements()`. The scene's own `mouse_pressed` dispatches through it (`UI.element_at(self:ui_elements(), mx, my)`), and draw uses its `enabled`/`selected` for styling. Specs, the game and the invariants therefore all read the same rects, so they cannot disagree about where a button is or whether it works.

### Entry shape

```lua
{ id = "cmd:run", label = "Run", kind = "button",
  rect = { x = 1087, y = 666, w = 42, h = 48 }, enabled = true, selected = false }
```

- `kind` is `"button"`, `"cell"` or `"slot"`.
- `enabled` is always a boolean. Include `selected` only when the element has a highlight state.
- Coordinates are logical 1280x720. Rects are half-open: `x <= px < x+w`, `y <= py < y+h`.
- Return a **fresh, deterministically ordered** array each call. Build it with `ipairs` over arrays, never with `pairs`. The call must have no side effects.
- A scene without `ui_elements` counts as having no elements.

Helpers in `lua/core/ui.lua` (this module requires no game modules):

```lua
local UI = require("lua/core/ui")
UI.hit(rect, x, y)            -- half-open point test
UI.element_at(elements, x, y) -- first element (list order) containing the point, or nil
UI.find(elements, id)         -- element by id, or nil
UI.centre(rect)               -- x, y rounded to whole pixels
UI.overlaps(a, b)             -- positive-area intersection (shared edges do not count)
```

---

## Invariants (checked every frame, cannot be disabled)

`UIRunner.check_invariants(elements)` runs these checks in order and reports the first violation:

1. **Well-formed:** a non-empty string `id` and `label`, `kind` in `button`/`cell`/`slot`, a numeric `rect` with `w > 0` and `h > 0`, and unique ids.
2. **On screen:** `0 <= x`, `x + w <= 1280`, `0 <= y`, `y + h <= 720`.
3. **No overlap:** no two rects intersect with positive area, whether enabled or disabled. Shared edges are fine.

Messages (the runner appends ` at frame <n>`):

```
invariant: malformed element <n>: <why>
invariant: duplicate id '<id>'
invariant: '<id>' off screen
invariant: '<idA>' overlaps '<idB>'
```

These checks run on every frame of every spec. A layout collision between two features therefore fails some spec without anyone writing a specific test for it.

---

## Reading failures

```
FAIL  tests/ui/<file>.lua :: <spec name> — step <i> <step serialised as Lua> — <reason>
```

- `<i>` is the 1-based index into `steps`. The step is printed with sorted keys, e.g. `{click_button = "Start"}`.
- The spec stops at its first failure. Other specs still run.
- `setup — <reason>` means the failure happened before step 1 (crash on the first frame, an invariant on the opening screen).
- A Lua error inside the game shows up as the reason, with its file and line.

| Reason | Usual cause |
|---|---|
| `no visible element labelled 'X'` / `no visible element id 'X'` | Wrong scene (check the previous step), the element is not registered, or a typo. |
| `element '<id>' is disabled` | The game state does not allow it yet. Use `click` if you are testing that a disabled button does nothing. |
| `ambiguous label 'X' (n matches)` | Switch to `{ id = ... }`. |
| `text 'X' not drawn` / `text 'X' was drawn` | Text is matched per frame. A typo, or the text is drawn on a different frame or scene. |
| `wait_until exceeded N frames` | The condition never became true. Raise `max_frames` only if the run is genuinely long. |
| `fade did not finish` | A scene transition is stuck, or something keeps switching scenes. |
| `matrix is {...}, expected {...}` | Logic error or wrong setup steps. |
| `tile at x,y ...` | Placement failed (wrong tool selected, locked cell, cell occupied). |
| `invariant: ... at frame N` | A real layout bug. Fix the layout, not the spec. |
| `scene has no matrix` / `scene has no tiles` | Matrix assert used on a scene that doesn't implement `ui_matrix()`/`ui_tile()`. |

---

## Adding `ui_elements()` to a scene

1. **Keep layout rects in one place.** Compute them in `new`/`load` (or in `draw` if they depend on drawn state) and store them on `self`. Use constants, not font metrics.
2. **Implement the registry** with a fresh, ordered array:

   ```lua
   local UI = require("lua/core/ui")

   function MyScene:ui_elements()
       local out = {}
       for _, b in ipairs(self._buttons) do          -- ipairs, never pairs
           out[#out + 1] = {
               id = "my:" .. b.key, label = b.label, kind = "button",
               rect = { x = b.x, y = b.y, w = b.w, h = b.h },   -- copy, do not share
               enabled = self:_can(b.key),                       -- one function shared with draw and keys
               selected = (b.key == self._current) or nil,       -- include only if it has a highlight state
           }
       end
       return out
   end
   ```

3. **Route input through it:**

   ```lua
   function MyScene:mouse_pressed(mx, my, btn)
       local e = UI.element_at(self:ui_elements(), mx, my)
       if not (e and e.enabled) then return end
       if e.id == "my:ok" then self:_ok() end
   end
   ```

4. **Draw from the same state.** Style each button from its element's `enabled`/`selected`. Keyboard shortcuts should check the same enabled function the registry uses.
5. **Pick ids** as `<scene>:<thing>` and keep them stable. Specs depend on them. Labels are the text the player sees.
6. **Write a spec** in `tests/ui/NN_<feature>.lua` that reaches the scene through real input and clicks the new elements. Run `love . --headless tests/ui/NN_<feature>.lua`, then the full suite.
7. If the scene shows a grid or matrix, implement `ui_matrix()` / `ui_tile(x, y)` (read-only) to enable the matrix and tile asserts.

## Writing a unit test

A unit test is a plain Lua script in `tests/test_<thing>.lua`. Any uncaught error fails the file. That includes a failed `assert`, so give every `assert` a message. Printing `PASS: <case>` lines is a convention, not a requirement.

```lua
local Camera = require("lua/core/camera")
local c = Camera.new(0, 0, 800, 600)
assert(c._w == 800, "camera width should be 800")
assert(c._h == 600, "camera height should be 600")
print("PASS: camera stores dimensions")
```

To test a scene, build it through the runner so it gets a real `SceneManager` and `HeadlessInput`:

```lua
local runner = require("lua/headless/runner")
local ctx = runner.setup(function(input, sm)
    return require("lua/game/scenes/game_scene").new()
end)
runner.tick(ctx.input, ctx.sm, 10)   -- 10 frames of update (dt 1/60)
local scene = ctx.sm.current
```

- `HeadlessInput` (`lua/headless/input.lua`) scripts actions: `press(action)` fires for one frame; `hold`/`release` keep an action down.
- `runner.fast_forward_until(ctx, condition_fn, elapsed, cap)` ticks until the condition holds.
- Prefer the scene's public input methods (`key_pressed`, `mouse_pressed`, `mouse_moved`) and `ui_elements()` over private `_methods`. Calling private methods is fine for logic, but it does not count as UI coverage.
- `love . --visual tests/test_<thing>.lua` runs the same test in a real window and renders every frame, so you can watch what it does. It is a debugging aid only; CI never uses it.
