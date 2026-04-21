#!/usr/bin/env bash
set -euo pipefail

# Build and package an unsigned iOS IPA for local tools like LiveContainer.
# Usage:
#   ./scripts/build_ios_unsigned_ipa.sh
#   ./scripts/build_ios_unsigned_ipa.sh OutputName.ipa

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_NAME="${1:-PicHoro-unsigned.ipa}"
ARCHIVE_APP_PATH="$PROJECT_ROOT/build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app"
IPA_DIR="$PROJECT_ROOT/build/ios/ipa"
PAYLOAD_DIR="$IPA_DIR/Payload"

cd "$PROJECT_ROOT"

if ! command -v fvm >/dev/null 2>&1; then
  echo "Error: fvm not found. Please install FVM or adjust this script to use flutter directly." >&2
  exit 1
fi

echo "[1/3] Building iOS archive without code signing..."
fvm flutter build ipa --no-codesign

if [[ ! -d "$ARCHIVE_APP_PATH" ]]; then
  echo "Error: archive app not found at: $ARCHIVE_APP_PATH" >&2
  exit 1
fi

echo "[2/3] Packaging unsigned ipa..."
rm -rf "$IPA_DIR"
mkdir -p "$PAYLOAD_DIR"
cp -R "$ARCHIVE_APP_PATH" "$PAYLOAD_DIR/"
(
  cd "$IPA_DIR"
  /usr/bin/zip -qry "$OUTPUT_NAME" Payload
)

echo "[3/3] Done"
echo "Output: $IPA_DIR/$OUTPUT_NAME"
wc -c "$IPA_DIR/$OUTPUT_NAME"
