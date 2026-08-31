#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
state="$HOME/.android-ai-appmaker"; sdk="$state/sdk"; mkdir -p "$state" "$sdk"
required='curl unzip python openjdk-21'; pkg update -y
for package in $required; do
  pkg install -y "$package" >/dev/null || { echo "必須パッケージを導入できませんでした: $package" >&2; exit 1; }
  case "$package" in curl) command -v curl;; unzip) command -v unzip;; python) command -v python;; openjdk-21) command -v javac;; esac >/dev/null || { echo "コマンドが見つかりません: $package" >&2; exit 1; }
done
download_verify() { url="$1"; sha="$2"; out="$3"; tmp="$out.part"; curl -fL --retry 3 "$url" -o "$tmp"; printf '%s  %s\n' "$sha" "$tmp" | sha256sum -c - >/dev/null || { rm -f "$tmp"; echo "SHA-256検証に失敗しました: $url" >&2; exit 1; }; mv -f "$tmp" "$out"; }
platform="$state/platform-35_r02.zip"; [ -f "$platform" ] && printf '%s  %s\n' '0988cacad01b38a18a47bac14a0695f246bc76c1b06c0eeb8eb0dc825ab0c8e0' "$platform" | sha256sum -c - >/dev/null || download_verify 'https://dl.google.com/android/repository/platform-35_r02.zip' '0988cacad01b38a18a47bac14a0695f246bc76c1b06c0eeb8eb0dc825ab0c8e0' "$platform"
mkdir -p "$sdk/platforms/android-35"; unzip -p "$platform" 'android-35/android.jar' > "$sdk/platforms/android-35/android.jar.part"; test -s "$sdk/platforms/android-35/android.jar.part"; mv -f "$sdk/platforms/android-35/android.jar.part" "$sdk/platforms/android-35/android.jar"
bt="$state/build-tools_r35_linux.zip"; [ -f "$bt" ] && printf '%s  %s\n' 'bd3a4966912eb8b30ed0d00b0cda6b6543b949d5ffe00bea54c04c81e1561d88' "$bt" | sha256sum -c - >/dev/null || download_verify 'https://dl.google.com/android/repository/build-tools_r35_linux.zip' 'bd3a4966912eb8b30ed0d00b0cda6b6543b949d5ffe00bea54c04c81e1561d88' "$bt"
btroot="$sdk/build-tools/35.0.0"; mkdir -p "$btroot/lib"; extract="$state/build-tools.extract"; rm -rf "$extract"; mkdir -p "$extract"; unzip -q "$bt" 'android-15/*' -d "$extract"; test -s "$extract/android-15/lib/d8.jar"; test -s "$extract/android-15/aapt2"; test -s "$extract/android-15/apksigner"; test -s "$extract/android-15/zipalign"; cp -R "$extract/android-15/." "$btroot/"; rm -rf "$extract"
chmod +x "$btroot/aapt2" "$btroot/apksigner" "$btroot/zipalign"; mkdir -p "$HOME/android-ai-appmaker/out"
echo 'Android build toolsの準備が完了しました（Codexは初回電卓に不要です）。'
