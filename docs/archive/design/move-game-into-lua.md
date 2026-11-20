# Move `game/` into `lua/`

## Goal

Relocate the top-level `game/` directory to `lua/game/` so all Lua source lives
under a single `lua/` root — consistent with how `lua/core/` and `lua/headless/`
are already organised.

## Affected files

| File | Change |
|------|--------|
| `game/player.lua` | Move → `lua/game/player.lua` |
| `game/scenes/game_scene.lua` | Move → `lua/game/scenes/game_scene.lua` |
| `main.lua` | Update `require("game/scenes/game_scene")` → `require("lua/game/scenes/game_scene")` |
| `lua/game/scenes/game_scene.lua` | Update `require("game/player")` → `require("lua/game/player")` |
| `tests/test_basics.lua` | Update `require("game/scenes/game_scene")` → `require("lua/game/scenes/game_scene")` |
| `tests/test_scene.lua` | Update `require("game/scenes/game_scene")` → `require("lua/game/scenes/game_scene")` |
| `scripts/build_web.sh` | Remove `game/` from zip args (already covered by `lua/`) |
| `README.md` | Update structure table and fix pre-existing wrong path (`core/lua/` → `lua/core/`) |

## What changes

- `game/` is deleted; its contents live at `lua/game/` and `lua/game/scenes/`.
- Every `require("game/...")` becomes `require("lua/game/...")`.
- The web build zip no longer lists `game/` separately; `lua/` already includes it.
- README structure section reflects the new layout.

## What stays the same

- All game logic, player movement, scene behaviour — no functional changes.
- Test infrastructure (`lua/headless/`, `tests/`) — only require paths change.
- CI workflows (`ci.yml`, `web.yml`) — no changes needed; they run `love .` and `build_web.sh`.
- Assets, conf.lua, package.json — untouched.

## Open questions

None — the mapping is unambiguous and all call sites are within this repo.
