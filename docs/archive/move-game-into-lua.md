# Move `game/` into `lua/` Checklist

- [x] Task A — `lua/game/player.lua` (new), `game/player.lua` (delete) — copy `game/player.lua` to `lua/game/player.lua`; delete `game/player.lua`
- [x] Task B — `lua/game/scenes/game_scene.lua` (new), `game/scenes/game_scene.lua` (delete) — copy `game/scenes/game_scene.lua` to `lua/game/scenes/game_scene.lua`; update its `require("game/player")` to `require("lua/game/player")`; delete the old file and empty `game/` tree
- [x] Task C — `main.lua` — update `require("game/scenes/game_scene")` to `require("lua/game/scenes/game_scene")`
- [x] Task D — `tests/test_basics.lua` — update `require("game/scenes/game_scene")` to `require("lua/game/scenes/game_scene")`
- [x] Task E — `tests/test_scene.lua` — update `require("game/scenes/game_scene")` to `require("lua/game/scenes/game_scene")`
- [x] Task F — `scripts/build_web.sh` — remove `game/` from the `zip` command args (it is now inside `lua/`)
- [x] Task G — `README.md` — update structure table: `game/` row → `lua/game/`; fix pre-existing wrong path `core/lua/` → `lua/core/`; remove stale `core/lua/README.md` link
