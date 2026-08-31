#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
pkg update -y
pkg install -y curl git python nodejs clang openjdk-21 zip unzip aapt2 apksigner zipalign
mkdir -p "$HOME/.local/bin" "$HOME/android-ai-appmaker/out"
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
codex_ok=false
if command -v codex >/dev/null 2>&1; then codex_ok=true; fi
if [ "$codex_ok" = false ]; then
  echo '公式standalone installerを試します。'
  if curl -fsSL https://chatgpt.com/codex/install.sh | sh; then
    hash -r 2>/dev/null || true
    command -v codex >/dev/null 2>&1 && codex_ok=true
  fi
fi
if [ "$codex_ok" = false ] && command -v npm >/dev/null 2>&1; then
  echo '公式npm packageを試します。'
  if npm install -g @openai/codex; then
    hash -r 2>/dev/null || true
    command -v codex >/dev/null 2>&1 && codex_ok=true
  fi
fi
if [ "$codex_ok" = true ]; then
  echo '公式Codex CLIを導入または検出しました。未認証なら codex login を実行してください。'
else
  echo '公式standalone installer/npm packageはいずれも利用できませんでした。第三者forkは使用しません。' >&2
  echo 'テンプレートモードでWeb UIとAPK生成を利用できます。' >&2
fi
echo 'Web UI: http://127.0.0.1:8765/'
