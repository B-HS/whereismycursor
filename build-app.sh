#!/usr/bin/env bash
set -euo pipefail

CONFIG="${1:-release}"
APP_NAME="CursorSpotlight"
BUNDLE_NAME="Where is my cursor"
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$ROOT_DIR/.build"
APP_DIR="$BUILD_DIR/$BUNDLE_NAME.app"

echo "==> Building ($CONFIG)"
cd "$ROOT_DIR"
swift build -c "$CONFIG" --product "$APP_NAME"

BIN_PATH=$(swift build -c "$CONFIG" --show-bin-path)

echo "==> Assembling $APP_DIR"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

cp "$BIN_PATH/$APP_NAME" "$APP_DIR/Contents/MacOS/$APP_NAME"
cp "$ROOT_DIR/Resources/Info.plist" "$APP_DIR/Contents/Info.plist"
cp "$ROOT_DIR/Resources/AppIcon.icns" "$APP_DIR/Contents/Resources/AppIcon.icns"

for lproj in "$ROOT_DIR/Resources/"*.lproj; do
    [ -d "$lproj" ] || continue
    name=$(basename "$lproj")
    mkdir -p "$APP_DIR/Contents/Resources/$name"
    cp -R "$lproj/"* "$APP_DIR/Contents/Resources/$name/"
done

echo "==> Ad-hoc codesign"
codesign --force --deep --sign - "$APP_DIR"

echo "==> Done: $APP_DIR"
echo "Launch with: open \"$APP_DIR\""
