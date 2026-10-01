#!/usr/bin/env bash
# ringenv local installer for Linux and macOS
set -e

echo "================================================="
echo "Installing ringenv CLI to active Ring environment"
echo "================================================="

RING_EXE="$(command -v ring 2>/dev/null || true)"
if [ -z "$RING_EXE" ]; then
    echo "Error: 'ring' binary not found in PATH."
    exit 1
fi

RING_BIN="$(dirname "$RING_EXE")"
RING_ROOT="$(cd "$RING_BIN/.." && pwd)"
TARGET_PKG="$RING_ROOT/tools/ringpm/packages/ringenv"

echo "Found Ring binary directory: $RING_BIN"
echo "Target package directory:    $TARGET_PKG"

mkdir -p "$TARGET_PKG/src/core" "$TARGET_PKG/src/commands" "$TARGET_PKG/bin" "$TARGET_PKG/docs"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cp "$SCRIPT_DIR/main.ring" "$TARGET_PKG/"
cp "$SCRIPT_DIR/package.ring" "$TARGET_PKG/"
cp "$SCRIPT_DIR/README.md" "$TARGET_PKG/"
cp "$SCRIPT_DIR/src/core/"*.ring "$TARGET_PKG/src/core/"
cp "$SCRIPT_DIR/src/commands/"*.ring "$TARGET_PKG/src/commands/"
cp "$SCRIPT_DIR/bin/ringenv.bat" "$TARGET_PKG/bin/"
cp "$SCRIPT_DIR/bin/ringenv" "$TARGET_PKG/bin/"
cp "$SCRIPT_DIR/docs/"*.md "$TARGET_PKG/docs/"

cp "$SCRIPT_DIR/bin/ringenv" "$RING_BIN/ringenv"
chmod +x "$RING_BIN/ringenv"
chmod +x "$TARGET_PKG/bin/ringenv"

echo "================================================="
echo "ringenv successfully installed!"
echo "You can now use 'ringenv' from any directory:"
echo "  ringenv --version"
echo "  ringenv list"
echo "  ringenv install 1.27"
echo "  ringenv venv create .rvenv --version 1.27"
echo "================================================="
