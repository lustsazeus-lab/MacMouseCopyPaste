#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="MouseCopyPaste"
BUILD_DIR="$ROOT_DIR/.build/release"
DIST_DIR="$ROOT_DIR/dist"
APP_DIR="$DIST_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

swift build --package-path "$ROOT_DIR" -c release

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"
cp "$BUILD_DIR/$APP_NAME" "$MACOS_DIR/$APP_NAME"
cp "$ROOT_DIR/Sources/MouseCopyPasteApp/Resources/StatusIconTemplate.png" "$RESOURCES_DIR/StatusIconTemplate.png"
cp "$ROOT_DIR/Assets/MouseCopyPaste.icns" "$RESOURCES_DIR/MouseCopyPaste.icns"

RESOURCE_BUNDLE="$BUILD_DIR/MouseCopyPaste_MouseCopyPasteApp.bundle"
if [[ -d "$RESOURCE_BUNDLE" ]]; then
  cp -R "$RESOURCE_BUNDLE" "$RESOURCES_DIR/"
fi

cat > "$CONTENTS_DIR/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleIconFile</key>
  <string>MouseCopyPaste</string>
  <key>CFBundleExecutable</key>
  <string>MouseCopyPaste</string>
  <key>CFBundleIdentifier</key>
  <string>local.mousecopypaste.app</string>
  <key>CFBundleName</key>
  <string>MouseCopyPaste</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>1.1.0</string>
  <key>CFBundleVersion</key>
  <string>2</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSHumanReadableCopyright</key>
  <string>Local utility for mouse copy and paste shortcuts.</string>
</dict>
</plist>
PLIST

codesign --force --sign - "$APP_DIR"
echo "$APP_DIR"
