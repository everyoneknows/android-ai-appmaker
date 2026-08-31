#!/usr/bin/env bash
set -euo pipefail
src="${1:?source directory}"; out="${2:?output apk}"
SDK="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$HOME/.android-ai-appmaker/sdk}}"
platform="${ANDROID_PLATFORM:-android-35}"
bt="${ANDROID_BUILD_TOOLS:-35.0.0}"
toolroot="$SDK/build-tools/$bt"
aapt2="${AAPT2:-$(command -v aapt2 2>/dev/null || true)}"
zipalign="${ZIPALIGN:-$(command -v zipalign 2>/dev/null || true)}"
d8jar="${D8_JAR:-$toolroot/lib/d8.jar}"
apksignerjar="${APKSIGNER_JAR:-$toolroot/lib/apksigner.jar}"
jdk25root="${JDK25_ROOT:-${PREFIX:-$HOME/.android-ai-appmaker/jdk-25}/lib/jvm/java-25-openjdk}"
java25="$jdk25root/bin/java"; javac25="$jdk25root/bin/javac"; keytool25="$jdk25root/bin/keytool"
jar="$SDK/platforms/$platform/android.jar"
[ -s "$jar" ] && [ -x "$aapt2" ] && [ -x "$java25" ] && [ -x "$javac25" ] && [ -x "$keytool25" ] && [ -s "$d8jar" ] && [ -s "$apksignerjar" ] && [ -x "$zipalign" ] && command -v zip >/dev/null && command -v unzip >/dev/null || { echo "不足: JDK25(java/javac/keytool)/android.jar/d8.jar/apksigner.jar/aapt2/zip/zipalign/unzip。Termuxを確認" >&2; exit 1; }
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/classes" "$tmp/gen" "$tmp/res" "$tmp/dex" "$(dirname "$out")"
find "$src" -name '*.java' -print0 | xargs -0 "$javac25" -source 8 -target 8 -classpath "$SDK/platforms/$platform/android.jar" -d "$tmp/classes"
mapfile -d '' class_files < <(find "$tmp/classes" -type f -name '*.class' -print0)
[ "${#class_files[@]}" -gt 0 ] || { echo 'class fileが生成されませんでした' >&2; exit 1; }
"$java25" -cp "$d8jar" com.android.tools.r8.D8 --lib "$jar" --output "$tmp/dex" "${class_files[@]}"
"$aapt2" link --manifest "$src/AndroidManifest.xml" --min-sdk-version 23 --target-sdk-version 35 -I "$jar" -o "$tmp/resources.apk"
cp "$tmp/resources.apk" "$tmp/unsigned.apk"; (cd "$tmp" && zip -q -j unsigned.apk dex/classes.dex)
key="$HOME/.android-ai-appmaker/release.keystore"; mkdir -p "$(dirname "$key")"
if [ ! -f "$key" ]; then "$keytool25" -genkeypair -keystore "$key" -storepass android -alias appmaker -keypass android -dname 'CN=android-ai-appmaker' -keyalg RSA -keysize 2048 -validity 10000 >/dev/null 2>&1; chmod 600 "$key"; fi
"$zipalign" -f 4 "$tmp/unsigned.apk" "$tmp/aligned.apk"
final="$out.part"; rm -f "$final"
"$java25" -jar "$apksignerjar" sign --ks "$key" --ks-pass pass:android --ks-key-alias appmaker --key-pass pass:android --out "$final" "$tmp/aligned.apk"
"$java25" -jar "$apksignerjar" verify "$final" >/dev/null
mv -f "$final" "$out"
rm -f "$final.idsig"
