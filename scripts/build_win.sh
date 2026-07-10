#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/config.sh
source scripts/config.sh

LOVE_URL="https://github.com/love2d/love/releases/download/${LOVE_VERSION}/love-${LOVE_VERSION}-win64.zip"
RUNTIME_DIR="dist/runtimes"
RUNTIME_ZIP="${RUNTIME_DIR}/love-${LOVE_VERSION}-win64.zip"
RUNTIME_EXTRACTED="${RUNTIME_DIR}/love-${LOVE_VERSION}-win64"
OUT_DIR="dist/win"
ZIP_OUT="dist/${GAME_SLUG}-win.zip"

mkdir -p "$RUNTIME_DIR" "$OUT_DIR"

if [ ! -f "$RUNTIME_ZIP" ]; then
    echo "Downloading LÖVE ${LOVE_VERSION} for Windows..."
    curl -L "$LOVE_URL" -o "$RUNTIME_ZIP"
fi

if [ ! -d "$RUNTIME_EXTRACTED" ]; then
    echo "Extracting LÖVE runtime..."
    unzip -q "$RUNTIME_ZIP" -d "$RUNTIME_DIR"
fi

echo "Building game.love..."
GAME_LOVE="dist/game.love"
rm -f "$GAME_LOVE"
zip -q -r "$GAME_LOVE" main.lua conf.lua lua/ game/ assets/

echo "Fusing love.exe + game.love..."
rm -rf "${OUT_DIR:?}/"*
cp "$RUNTIME_EXTRACTED/"*.dll "$OUT_DIR/"
cp "$RUNTIME_EXTRACTED/license.txt" "$OUT_DIR/" 2>/dev/null || true
cat "$RUNTIME_EXTRACTED/love.exe" "$GAME_LOVE" > "${OUT_DIR}/${GAME_SLUG}.exe"

echo "Setting icon..."
python3 scripts/make_ico.py assets/images/icon.png "${OUT_DIR}/icon.ico"

rm "$GAME_LOVE"

echo "Zipping..."
rm -f "$ZIP_OUT"
cd "$OUT_DIR"
zip -q -r "../../$ZIP_OUT" .
cd ../..

echo "Done → ${ZIP_OUT}"
