#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

case "$(id -u)" in 0) echo 'rootでは実行しません。Termuxの通常ユーザーで実行してください。' >&2; exit 1;; esac
[ -n "${PREFIX:-}" ] || { echo 'Termux上で実行してください。' >&2; exit 1; }

repo="${APPMAKER_REPO_URL:-https://raw.githubusercontent.com/YOUR_GITHUB_USER/android-ai-appmaker/COMMIT_OR_TAG}"
base="$HOME/.android-ai-appmaker/source"
mkdir -p "$base/scripts" "$HOME/.local/bin"
for file in scripts/termux-install.sh scripts/ai-adapter.sh builder/build-apk.sh bin/appmaker examples/stopwatch-clock/AndroidManifest.xml examples/stopwatch-clock/src/com/example/stopwatch/MainActivity.java; do
  mkdir -p "$base/$(dirname "$file")"
  curl -fsSL "$repo/$file" -o "$base/$file"
done
chmod +x "$base"/scripts/*.sh "$base"/builder/build-apk.sh "$base"/bin/appmaker
"$base/scripts/termux-install.sh"
ln -sf "$base/bin/appmaker" "$HOME/.local/bin/appmaker"
echo
echo '準備完了。PowerShellでREADMEの1行を実行し、接続後に appmaker を起動してください。'
