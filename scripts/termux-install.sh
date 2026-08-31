#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
pkg update -y
pkg install -y curl openssh git python nodejs clang openjdk-21 zip unzip aapt2 apksigner zipalign
mkdir -p "$HOME/.local/bin" "$HOME/android-ai-appmaker/out"
if ! command -v sshd >/dev/null; then echo 'opensshの導入に失敗しました' >&2; exit 1; fi
sdk="$HOME/.android-ai-appmaker/sdk"
if [ ! -f "$sdk/platforms/android-35/android.jar" ]; then
  mkdir -p "$sdk/platforms/android-35"
  curl -fsSL https://dl.google.com/android/repository/platform-35_r02.zip -o "$HOME/.android-ai-appmaker/platform.zip"
  unzip -q -j "$HOME/.android-ai-appmaker/platform.zip" 'android-35/android.jar' -d "$sdk/platforms/android-35"
fi
d8jar="$sdk/build-tools/35.0.0/lib/d8.jar"
if [ ! -f "$d8jar" ]; then
  mkdir -p "$(dirname "$d8jar")"
  buildtools="$HOME/.android-ai-appmaker/build-tools.zip"
  curl -fsSL https://dl.google.com/android/repository/build-tools_r35.0.0-linux.zip -o "$buildtools"
  unzip -q -j "$buildtools" 'android-15/lib/d8.jar' -d "$(dirname "$d8jar")"
fi
if command -v npm >/dev/null 2>&1; then
  if command -v codex >/dev/null 2>&1; then
    echo '公式Codex CLIを検出しました。'
  elif npm install -g @openai/codex; then
    echo '公式Codex CLIを導入しました。初回利用時は codex --login を実行してください。'
  else
    echo '公式Codex CLIはTermuxで導入できませんでした。第三者forkは使用しません。'
    echo 'テンプレートモードでWeb UIとAPK生成を利用できます。' >&2
  fi
else
  echo 'npmが利用できないため、公式Codex CLIは導入していません。テンプレートモードを使用します。'
fi
echo 'Web UI: http://127.0.0.1:8765/'
