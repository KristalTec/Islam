#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLUTTER_DIR="$REPO_ROOT/flutter_app"
WORKFLOW_DIR="$REPO_ROOT/.github/workflows"
WORKFLOW_FILE="$WORKFLOW_DIR/build.yml"
EXPECTED_DART_FILES=49
COMMIT_MESSAGE="Automated Native Flutter Migration and Build Pipeline"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Error: required command '$1' is not installed." >&2
    exit 1
  }
}

require_cmd git
require_cmd flutter

if [[ ! -d "$FLUTTER_DIR" ]]; then
  echo "Error: $FLUTTER_DIR does not exist." >&2
  exit 1
fi

actual_dart_files=$(find "$FLUTTER_DIR" -type f -name '*.dart' | wc -l | tr -d '[:space:]')
if [[ "$actual_dart_files" -ne "$EXPECTED_DART_FILES" ]]; then
  echo "Error: Expected $EXPECTED_DART_FILES Dart files in $FLUTTER_DIR but found $actual_dart_files." >&2
  exit 1
fi

echo "Validated flutter_app structure: $actual_dart_files Dart files found."

mkdir -p "$WORKFLOW_DIR"

cat > "$WORKFLOW_FILE" <<'YAML'
name: Flutter Native Build

on:
  push:
    branches: ["main"]
  pull_request:
    branches: ["main"]
  workflow_dispatch:

permissions:
  contents: read

jobs:
  android-release:
    name: Android APK Release
    runs-on: macos-latest
    defaults:
      run:
        working-directory: flutter_app
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Java 17
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Build Android release APK
        run: flutter build apk --release

      - name: Upload APK artifact
        uses: actions/upload-artifact@v4
        with:
          name: android-apk-release
          path: flutter_app/build/app/outputs/flutter-apk/app-release.apk

  ios-release:
    name: iOS Runner.app and IPA (no codesign)
    runs-on: macos-latest
    defaults:
      run:
        working-directory: flutter_app
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Java 17
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Build iOS app (no codesign)
        run: flutter build ios --release --no-codesign

      - name: Package no-codesign IPA
        run: |
          rm -rf build/ios/ipa_payload
          mkdir -p build/ios/ipa_payload/Payload
          cp -R build/ios/iphoneos/Runner.app build/ios/ipa_payload/Payload/Runner.app
          (cd build/ios/ipa_payload && zip -r ../Runner-no-codesign.ipa Payload)

      - name: Upload Runner.app artifact
        uses: actions/upload-artifact@v4
        with:
          name: ios-runner-app
          path: flutter_app/build/ios/iphoneos/Runner.app

      - name: Upload IPA artifact
        uses: actions/upload-artifact@v4
        with:
          name: ios-no-codesign-ipa
          path: flutter_app/build/ios/Runner-no-codesign.ipa
YAML

echo "Generated workflow: $WORKFLOW_FILE"

git -C "$REPO_ROOT" add "$WORKFLOW_FILE" "$REPO_ROOT/automate_flutter_migration.sh"

if git -C "$REPO_ROOT" diff --cached --quiet; then
  echo "No changes to commit."
else
  git -C "$REPO_ROOT" commit -m "$COMMIT_MESSAGE"
  git -C "$REPO_ROOT" push origin main
  echo "Changes committed and pushed to origin/main."
fi
