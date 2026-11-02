#!/bin/sh

# Xcode Cloud starts from a clean checkout. Flutter's iOS integration creates
# Generated.xcconfig and the Swift packages referenced by Runner.xcodeproj at
# build time, so they must be generated after the repository is cloned.
set -eu

cd "${CI_PRIMARY_REPOSITORY_PATH:?CI_PRIMARY_REPOSITORY_PATH is not set}"

# Keep the cloud build aligned with the Flutter SDK used to generate the
# checked-in iOS project. Override this in Xcode Cloud only when upgrading the
# project deliberately.
FLUTTER_VERSION="${FLUTTER_VERSION:-3.47.7}"
FLUTTER_DIR="${HOME}/flutter-${FLUTTER_VERSION}"

if [ ! -x "${FLUTTER_DIR}/bin/flutter" ]; then
  git clone \
    --depth 1 \
    --branch "${FLUTTER_VERSION}" \
    https://github.com/flutter/flutter.git \
    "${FLUTTER_DIR}"
fi

export FLUTTER_ROOT="${FLUTTER_DIR}"
export PATH="${FLUTTER_ROOT}/bin:${PATH}"

flutter --version
flutter precache --ios
flutter pub get

# Generate Generated.xcconfig and FlutterGeneratedPluginSwiftPackage before
# Xcode resolves the local Swift package references in Runner.xcodeproj.
flutter build ios --config-only --release --no-codesign

test -f "ios/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/Package.swift"
