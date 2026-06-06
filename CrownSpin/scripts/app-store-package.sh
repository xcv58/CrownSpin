#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_PATH="$ROOT_DIR/CrownSpin/CrownSpin.xcodeproj"
EXPORT_OPTIONS="$ROOT_DIR/CrownSpin/AppStoreExportOptions.plist"
ARCHIVE_PATH="${ARCHIVE_PATH:-/tmp/CrownSpin-submit.xcarchive}"
EXPORT_PATH="${EXPORT_PATH:-/tmp/CrownSpin-submit-export}"
IPA_OUTPUT="$ROOT_DIR/CrownSpin/AppStoreBuilds/CrownSpin-1.0-1.ipa"
MODE="${1:-export}"

case "$MODE" in
  export|upload)
    ;;
  *)
    echo "Usage: $0 [export|upload]" >&2
    exit 64
    ;;
esac

mkdir -p "$(dirname "$IPA_OUTPUT")"
rm -rf "$ARCHIVE_PATH" "$EXPORT_PATH"

xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme CrownSpin \
  -configuration Release \
  -archivePath "$ARCHIVE_PATH" \
  -allowProvisioningUpdates \
  archive

if [[ "$MODE" == "upload" ]]; then
  TMP_EXPORT_OPTIONS="$(mktemp /tmp/CrownSpinUploadExportOptions.XXXXXX.plist)"
  cp "$EXPORT_OPTIONS" "$TMP_EXPORT_OPTIONS"
  /usr/libexec/PlistBuddy -c 'Set :destination upload' "$TMP_EXPORT_OPTIONS"
  xcodebuild \
    -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$TMP_EXPORT_OPTIONS" \
    -allowProvisioningUpdates
  rm -f "$TMP_EXPORT_OPTIONS"
else
  xcodebuild \
    -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS" \
    -allowProvisioningUpdates
  cp "$EXPORT_PATH/CrownSpin.ipa" "$IPA_OUTPUT"
  echo "Exported IPA: $IPA_OUTPUT"
fi
