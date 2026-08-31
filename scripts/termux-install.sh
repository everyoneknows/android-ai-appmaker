#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
state="$HOME/.android-ai-appmaker"; sdk="$state/sdk"; mkdir -p "$state" "$sdk"
required=(curl unzip zip python openjdk-25 coreutils aapt aapt2); pkg update -y
for package in "${required[@]}"; do
  pkg install -y "$package" >/dev/null || { echo "必須パッケージを導入できませんでした: $package" >&2; exit 1; }
  case "$package" in curl) command -v curl;; unzip) command -v unzip;; zip) command -v zip;; python) command -v python;; openjdk-25) :;; coreutils) command -v realpath && command -v readlink && command -v sha256sum && command -v find && command -v xargs;; aapt|aapt2) command -v "$package";; esac >/dev/null || { echo "コマンドが見つかりません: $package" >&2; exit 1; }
done
prefix="${PREFIX:?Termux PREFIXがありません}"
jdk25="$prefix/lib/jvm/java-25-openjdk/bin"; for command in java javac keytool; do test -x "$jdk25/$command" || { echo "JDK25 commandが見つかりません: $jdk25/$command" >&2; exit 1; }; done
commands=(curl unzip zip python aapt2 realpath readlink sha256sum find xargs zipalign)
for command in "${commands[@]}"; do command -v "$command" >/dev/null || { echo "必須commandが見つかりません: $command" >&2; exit 1; }; done
download_verify() { url="$1"; sha="$2"; out="$3"; tmp="$out.part"; rm -f -- "$tmp"; if ! curl -fL --retry 3 "$url" -o "$tmp"; then rm -f -- "$tmp"; echo "downloadに失敗しました: $url" >&2; exit 1; fi; if ! printf '%s  %s\n' "$sha" "$tmp" | sha256sum -c - >/dev/null; then rm -f -- "$tmp"; echo "SHA-256検証に失敗しました: $url" >&2; exit 1; fi; mv -f -- "$tmp" "$out"; }
platform="$state/platform-34-ext7_r03.zip"; [ -f "$platform" ] && printf '%s  %s\n' '16fdb74c55e59ae3ef52def135aec713508467bd56d7dabcd8c9be31fa8b20f3' "$platform" | sha256sum -c - >/dev/null || download_verify 'https://dl.google.com/android/repository/platform-34-ext7_r03.zip' '16fdb74c55e59ae3ef52def135aec713508467bd56d7dabcd8c9be31fa8b20f3' "$platform"
mkdir -p "$sdk/platforms/android-34"; jar_part="$sdk/platforms/android-34/android.jar.part"; rm -f -- "$jar_part"; if ! unzip -p "$platform" 'android-34/android.jar' > "$jar_part" || ! test -s "$jar_part"; then rm -f -- "$jar_part"; echo 'android.jarの展開に失敗しました' >&2; exit 1; fi; mv -f -- "$jar_part" "$sdk/platforms/android-34/android.jar"
bt="$state/build-tools_r35_linux.zip"; [ -f "$bt" ] && printf '%s  %s\n' 'bd3a4966912eb8b30ed0d00b0cda6b6543b949d5ffe00bea54c04c81e1561d88' "$bt" | sha256sum -c - >/dev/null || download_verify 'https://dl.google.com/android/repository/build-tools_r35_linux.zip' 'bd3a4966912eb8b30ed0d00b0cda6b6543b949d5ffe00bea54c04c81e1561d88' "$bt"
btroot="$sdk/build-tools/35.0.0"; mkdir -p "$btroot/lib"; extract="$state/build-tools.extract"; rm -rf "$extract"; mkdir -p "$extract"; unzip -q "$bt" 'android-15/lib/d8.jar' 'android-15/lib/apksigner.jar' -d "$extract"; test -s "$extract/android-15/lib/d8.jar"; test -s "$extract/android-15/lib/apksigner.jar"; cp -R "$extract/android-15/." "$btroot/"; rm -rf "$extract"
mkdir -p "$HOME/android-ai-appmaker/out"
echo 'Android build toolsの準備が完了しました（Google archiveはandroid.jar/d8.jar/apksigner.jarを使用し、native toolはTermux packageを使用します）。'
