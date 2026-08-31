#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
pkg update -y
pkg install -y curl openssh git python clang openjdk-21 zip unzip aapt2 apksigner zipalign || true
mkdir -p "$HOME/.local/bin" "$HOME/android-ai-appmaker/out"
if ! command -v sshd >/dev/null; then echo 'opensshの導入に失敗しました' >&2; exit 1; fi
sdk="$HOME/.android-ai-appmaker/sdk"
if [ ! -f "$sdk/platforms/android-35/android.jar" ]; then
  mkdir -p "$sdk/platforms/android-35"
  curl -fsSL https://dl.google.com/android/repository/platform-35_r02.zip -o "$HOME/.android-ai-appmaker/platform.zip"
  unzip -q -j "$HOME/.android-ai-appmaker/platform.zip" 'android-35/android.jar' -d "$sdk/platforms/android-35"
fi
if [ ! -f "$HOME/.ssh/authorized_keys" ] && [ ! -f "$HOME/.ssh/id_rsa" ]; then
  echo 'SSH鍵は未設定です。必要なら ssh-keygen -t ed25519 を一度実行してください。'
fi
if command -v codex >/dev/null; then echo '公式Codex CLIを検出しました。' ; else echo 'Codex CLIは未検出。安全なテンプレートモードで開始します。'; fi
echo 'sshd起動: sshd -p 8022'
echo '（端末再起動後も必要ならTermux:Boot等を別途設定してください）'
