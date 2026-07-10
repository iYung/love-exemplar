# love-exemplar

A minimal Love2D project demonstrating clean architecture patterns. Intended as a reference, not a game.

## Structure

```
core/lua/       Engine classes — no game knowledge (Camera, Drawer, Input, Scene,
                SceneManager, Sprite, SpriteSet, Timer, Fonts)
game/           Game-specific code (Player, GameScene)
lua/headless/   Headless test infrastructure (stubs, HeadlessInput, runner)
tests/          Test files — run with: love . --headless
assets/         Images and other assets
conf.lua        Window config; suppresses graphics/audio modules under --headless
main.lua        Entry point — canvas rendering with letterboxing, pixel-art filter
```

See [`core/lua/README.md`](core/lua/README.md) for API docs on each engine class.

## Running

```bash
love .                  # normal window
love . --headless       # run tests and exit
```

## Configuration

Edit `scripts/config.sh` once when forking for a new game:

```bash
APP_NAME="My Game"               # display name — window title, macOS bundle
GAME_SLUG="my-game"              # slug used in output filenames
BUNDLE_ID="com.example.my-game"  # macOS bundle identifier
ITCH_ACCOUNT="yourname"          # itch.io account slug
ITCH_GAME="my-game"              # itch.io game slug
LOVE_VERSION="11.5"
```

All build and push scripts source this file. Any variable can also be overridden inline: `APP_NAME="..." bash scripts/build_web.sh`.

## Web build

```bash
npm install
bash scripts/build_web.sh   # outputs to web/
```

## Native builds

Requires: `curl`, `zip`, `unzip`, `python3`, `Pillow` (`pip install Pillow`).

```bash
bash scripts/build_mac.sh   # → dist/{GAME_SLUG}-mac.zip  (macOS only — uses iconutil)
bash scripts/build_win.sh   # → dist/{GAME_SLUG}-win.zip
bash scripts/build_all.sh   # web + mac + win in sequence
```

LÖVE runtimes are downloaded once and cached in `dist/runtimes/`.

## Publishing to itch.io

Requires [butler](https://itch.io/docs/butler/) and `ITCH_ACCOUNT`/`ITCH_GAME` set in `scripts/config.sh`.

```bash
bash scripts/push_all.sh    # pushes web/, mac zip, and win zip to itch.io
```

## CI / Cloudflare Pages

Two GitHub Actions workflows are included:

- **`ci.yml`** — runs `love . --headless` on every push and PR
- **`web.yml`** — builds the web output and deploys to Cloudflare Pages

To activate the web deploy, see [`docs/setup-cloudflare.md`](docs/setup-cloudflare.md). In short, set these in your GitHub repository settings:

| Type | Name | Value |
|------|------|-------|
| Secret | `CLOUDFLARE_API_TOKEN` | your Cloudflare API token |
| Secret | `CLOUDFLARE_ACCOUNT_ID` | your Cloudflare account ID |
| Variable | `CLOUDFLARE_PROJECT_NAME` | your Cloudflare Pages project name |
| Variable | `APP_TITLE` | browser tab title (optional) |

PR previews are deployed automatically and linked in a PR comment. Production deploys on push to `master`.

## Architecture notes

- **Fixed logical resolution** — game renders to a `1280×720` canvas; `main.lua` scales it to the window with letterboxing. Works with any window size.
- **Scene transitions** — `SceneManager` fades through black (0.3 s) between scene switches.
- **Headless tests** — `lua/headless/stubs.lua` installs no-op love API replacements so test files run without a window. `HeadlessInput` lets tests script action presses frame-by-frame. See `tests/test_basics.lua` for a minimal example.
