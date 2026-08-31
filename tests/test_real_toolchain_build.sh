#!/usr/bin/env bash
set -euo pipefail

# Real Android toolchain integration. This is separate from the shell-safety
# test, whose compiler and APK tools are stubs.
root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
sdk="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$HOME/.android-ai-appmaker/sdk}}"
tools="$sdk/build-tools/35.0.0"
if [ ! -f "$sdk/platforms/android-35/android.jar" ] || [ ! -x "$tools/aapt2" ] || [ ! -x "$tools/zipalign" ] || [ ! -x "$tools/apksigner" ]; then
  echo 'SKIP: prepared real Android SDK/build-tools not found (not a stub PASS)' >&2
  exit 0
fi
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
HOME="$tmp/home" ANDROID_SDK_ROOT="$sdk" bash "$root/bin/appmaker" --sample >/dev/null
apk="$tmp/home/android-ai-appmaker/out/latest/app.apk"
[ -s "$apk" ]
unzip -t "$apk" >/dev/null
"$tools/apksigner" verify "$apk" >/dev/null
badging="$("$tools/aapt2" dump badging "$apk")"
grep -Fq "package: name='com.example.calculator'" <<< "$badging"
grep -Fq "launchable-activity: name='com.example.calculator.MainActivity'" <<< "$badging"
! grep -Fq 'uses-permission' <<< "$badging"
printf '%s\n' 'real Android toolchain build passed: APK, package, launcher, permission, signature'
