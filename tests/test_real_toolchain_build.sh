#!/usr/bin/env bash
set -euo pipefail

# Real Android toolchain integration. This is separate from the shell-safety
# test, whose compiler and APK tools are stubs.
root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
sdk="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$HOME/.android-ai-appmaker/sdk}}"
tools="$sdk/build-tools/35.0.0"; jdk25="${JDK25_ROOT:-${PREFIX:-$HOME/.android-ai-appmaker/jdk-25}/lib/jvm/java-25-openjdk}"
if [ ! -s "$sdk/platforms/android-34/android.jar" ] || [ ! -x "$tools/aapt2" ] || [ ! -x "$tools/zipalign" ] || [ ! -s "$tools/lib/d8.jar" ] || [ ! -s "$tools/lib/apksigner.jar" ] || [ ! -x "$jdk25/bin/java" ] || [ ! -x "$jdk25/bin/javac" ] || [ ! -x "$jdk25/bin/keytool" ]; then
  echo 'SKIPPED: prepared real Android SDK/build-tools not found; release gate is not successful' >&2
  exit 77
fi
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
HOME="$tmp/home" ANDROID_SDK_ROOT="$sdk" JDK25_ROOT="$jdk25" AAPT2="$tools/aapt2" ZIPALIGN="$tools/zipalign" APKSIGNER_JAR="$tools/lib/apksigner.jar" bash "$root/bin/appmaker" --sample >/dev/null
apk="$tmp/home/android-ai-appmaker/out/latest/app.apk"
[ -s "$apk" ]
unzip -t "$apk" >/dev/null
command -v zip >/dev/null
"$jdk25/bin/java" -jar "$tools/lib/apksigner.jar" verify "$apk" >/dev/null
badging="$("$tools/aapt2" dump badging "$apk")"
grep -Fq "package: name='com.example.calculator'" <<< "$badging"
grep -Fq "launchable-activity: name='com.example.calculator.MainActivity'" <<< "$badging"
! grep -Fq 'uses-permission' <<< "$badging"
printf '%s\n' 'real toolchain test: PASSED (explicit JDK25 javac/D8/keytool/apksigner, aapt2, zip, zipalign)'
