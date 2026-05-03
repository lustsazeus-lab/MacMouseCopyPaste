#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

cat > "$TEMP_DIR/main.swift" <<'SWIFT'
let mapping = MouseShortcutMapping()

precondition(mapping.shortcut(forMouseButton: 2) == .commandC)
precondition(mapping.shortcut(forMouseButton: 4) == .commandV)
precondition(mapping.shortcut(forMouseButton: 0) == nil)
precondition(mapping.shortcut(forMouseButton: 1) == nil)
precondition(mapping.shortcut(forMouseButton: 3) == nil)

print("mapping verification passed")
SWIFT

swiftc \
  "$ROOT_DIR/Sources/MouseCopyPasteCore/MouseShortcutMapping.swift" \
  "$TEMP_DIR/main.swift" \
  -o "$TEMP_DIR/verify_mapping"

"$TEMP_DIR/verify_mapping"
