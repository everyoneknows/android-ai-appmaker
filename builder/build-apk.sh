#!/usr/bin/env bash
set -euo pipefail
src="${1:?source directory}"; out="${2:?output apk}"
SDK="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$HOME/.android-ai-appmaker/sdk}}"
platform="${ANDROID_PLATFORM:-android-35}"
bt="${ANDROID_BUILD_TOOLS:-35.0.0}"
toolroot="$SDK/build-tools/$bt"
aapt2="${AAPT2:-$toolroot/aapt2}"; d8="${D8:-$toolroot/d8}"; apksigner="${APKSIGNER:-$toolroot/apksigner}"; zipalign="${ZIPALIGN:-$toolroot/zipalign}"
d8jar="${D8_JAR:-$toolroot/lib/d8.jar}"
jar="$SDK/platforms/$platform/android.jar"
[ -f "$jar" ] && [ -x "$aapt2" ] && { [ -x "$d8" ] || [ -f "$d8jar" ]; } && [ -x "$apksigner" ] && [ -x "$zipalign" ] || { echo "不足: android.jar/aapt2/d8/apksigner/zipalign。Termuxパッケージまたは環境変数を確認" >&2; exit 1; }
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/classes" "$tmp/gen" "$tmp/res" "$tmp/dex" "$(dirname "$out")"
find "$src" -name '*.java' -print0 | xargs -0 javac -source 8 -target 8 -classpath "$SDK/platforms/$platform/android.jar" -d "$tmp/classes"
if [ -x "$d8" ]; then
  "$d8" --lib "$jar" --output "$tmp/dex" $(find "$tmp/classes" -name '*.class')
else
  java -cp "$d8jar" com.android.tools.r8.D8 --lib "$jar" --output "$tmp/dex" $(find "$tmp/classes" -name '*.class')
fi
"$aapt2" link --manifest "$src/AndroidManifest.xml" -I "$jar" -o "$tmp/resources.apk"
cp "$tmp/resources.apk" "$tmp/unsigned.apk"; (cd "$tmp" && zip -q -j unsigned.apk dex/classes.dex)
key="$HOME/.android-ai-appmaker/release.keystore"; mkdir -p "$(dirname "$key")"
if [ ! -f "$key" ]; then keytool -genkeypair -keystore "$key" -storepass android -alias appmaker -keypass android -dname 'CN=android-ai-appmaker' -keyalg RSA -keysize 2048 -validity 10000 >/dev/null 2>&1; chmod 600 "$key"; fi
"$zipalign" -f 4 "$tmp/unsigned.apk" "$tmp/aligned.apk"
final="$out.part"; rm -f "$final"
"$apksigner" sign --ks "$key" --ks-pass pass:android --ks-key-alias appmaker --key-pass pass:android --out "$final" "$tmp/aligned.apk"
"$apksigner" verify "$final" >/dev/null
mv -f "$final" "$out"
rm -f "$final.idsig"
