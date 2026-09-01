#!/bin/bash

runFirebaseSetup() {
  local flavor="$1"

  if [[ -z "$flavor" ]]; then
    read -rp "Enter environment flavor (dev/exp/stage/prod): " flavor
  fi

  case $flavor in
    dev|exp|stage|prod) ;;
    *)
      echo "Error: Invalid environment specified. Use 'dev', 'exp', 'stage', or 'prod'."
      return 1
      ;;
  esac

  if [[ ! -f "scripts/firebase/firebase.env" ]]; then
    echo "Warning: scripts/firebase/firebase.env not found; using defaults." >&2
  else
    source "scripts/firebase/firebase.env"
  fi

  local default_project default_ios_bundle default_android_pkg
  case $flavor in
    dev)
      default_project="${dev_project:-flutter-app-template-b1e3c}"
      default_ios_bundle="${dev_ios_bundle:-com.ragibn5.fat.dev}"
      default_android_pkg="${dev_android_pkg:-com.ragibn5.fat.dev}"
      ;;
    exp)
      default_project="${exp_project:-flutter-app-template-b1e3c}"
      default_ios_bundle="${exp_ios_bundle:-com.ragibn5.fat.exp}"
      default_android_pkg="${exp_android_pkg:-com.ragibn5.fat.exp}"
      ;;
    stage)
      default_project="${stage_project:-flutter-app-template-b1e3c}"
      default_ios_bundle="${stage_ios_bundle:-com.ragibn5.fat.stage}"
      default_android_pkg="${stage_android_pkg:-com.ragibn5.fat.stage}"
      ;;
    prod)
      default_project="${prod_project:-flutter-app-template-b1e3c}"
      default_ios_bundle="${prod_ios_bundle:-com.ragibn5.fat}"
      default_android_pkg="${prod_android_pkg:-com.ragibn5.fat}"
      ;;
  esac

  local project ios_bundle android_pkg
  project=$(prompt_with_default "Enter Firebase project ID" "$default_project")
  ios_bundle=$(prompt_with_default "Enter iOS bundle ID" "$default_ios_bundle")
  android_pkg=$(prompt_with_default "Enter Android package name" "$default_android_pkg")

  local ios_out="ios/Config/Firebase/${flavor}/GoogleService-Info.plist"
  local android_out="android/app/src/${flavor}/google-services.json"
  local dart_out="lib/features/app/infrastructure/config/firebase/firebase_options_${flavor}.dart"

  echo -e "\nGenerating Firebase configuration with:"
  echo "Project: $project"
  echo "iOS Bundle ID: $ios_bundle"
  echo "Android Package: $android_pkg"
  echo "iOS Output: $ios_out"
  echo "Android Output: $android_out"
  echo "Dart Output: $dart_out"

  if ! confirm_yes_no "Continue?"; then
    echo "Aborted."
    return 0
  fi

  mkdir -p "ios/Config/Firebase/${flavor}"
  mkdir -p "android/app/src/${flavor}"
  mkdir -p "lib/features/app/infrastructure/config/firebase"

  echo -e "\nRunning flutterfire configure..."
  flutterfire configure \
    --project="$project" \
    --out="$dart_out" \
    --ios-bundle-id="$ios_bundle" \
    --ios-out="$ios_out" \
    --android-package-name="$android_pkg" \
    --android-out="$android_out"

  echo "Configuration complete for $flavor environment!"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/sources.sh"
  runFirebaseSetup "$@"
fi