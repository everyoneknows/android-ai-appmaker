#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

case "$(id -u)" in 0) echo 'rootでは実行しません。Termuxの通常ユーザーで実行してください。' >&2; exit 1;; esac
[ -n "${PREFIX:-}" ] || { echo 'Termux上で実行してください。' >&2; exit 1; }

repo="${APPMAKER_REPO_URL:-https://raw.githubusercontent.com/everyoneknows/android-ai-appmaker/v0.1.0}"
base="$HOME/.android-ai-appmaker/source"
mkdir -p "$base/scripts" "$HOME/.local/bin"
for file in scripts/termux-install.sh scripts/ai-adapter.sh builder/build-apk.sh bin/appmaker web/server.py web/index.html examples/stopwatch-clock/AndroidManifest.xml examples/stopwatch-clock/src/com/example/stopwatch/MainActivity.java; do
  mkdir -p "$base/$(dirname "$file")"
  curl -fsSL "$repo/$file" -o "$base/$file"
done
chmod +x "$base"/scripts/*.sh "$base"/builder/build-apk.sh "$base"/bin/appmaker
"$base/scripts/termux-install.sh"
ln -sf "$base/bin/appmaker" "$HOME/.local/bin/appmaker"
echo
echo '準備完了。ブラウザを開きます: http://127.0.0.1:8765/'
nohup python "$base/web/server.py" >"$HOME/.android-ai-appmaker/web.log" 2>&1 &
server_pid=$!
echo "$server_pid" > "$HOME/.android-ai-appmaker/web.pid"
if command -v termux-open-url >/dev/null 2>&1; then
  termux-open-url http://127.0.0.1:8765/ >/dev/null 2>&1 || true
else
  echo 'ブラウザで http://127.0.0.1:8765/ を開いてください。'
fi
