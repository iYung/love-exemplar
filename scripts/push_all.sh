#!/usr/bin/env bash
# Push all release targets to itch.io via butler.
# Run from the project root: bash scripts/push_all.sh
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/config.sh
source scripts/config.sh

if [ -z "$ITCH_ACCOUNT" ] || [ -z "$ITCH_GAME" ]; then
    echo "Error: set ITCH_ACCOUNT and ITCH_GAME in scripts/config.sh before pushing."
    exit 1
fi

echo "=== HTML5 ==="
butler push web/ "${ITCH_ACCOUNT}/${ITCH_GAME}:html5"

echo ""
echo "=== Mac ==="
butler push "dist/${GAME_SLUG}-mac.zip" "${ITCH_ACCOUNT}/${ITCH_GAME}:mac"

echo ""
echo "=== Windows ==="
butler push "dist/${GAME_SLUG}-win.zip" "${ITCH_ACCOUNT}/${ITCH_GAME}:windows"

echo ""
echo "All pushes complete."
