#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
# Immutable bootstrap for the rc7 content commit.
case "$(id -u)" in 0) echo 'rootでは実行しません。Termuxの通常ユーザーで実行してください。' >&2; exit 1;; esac
[ -n "${PREFIX:-}" ] || { echo 'Termux上で実行してください。' >&2; exit 1; }
DEFAULT_APPMAKER_REF="4b9c5b180a8eb0d2a5c54609ea3cc1568c7d0941"
APPMAKER_REF="${APPMAKER_REF:-$DEFAULT_APPMAKER_REF}"
[ "${#APPMAKER_REF}" -eq 40 ] && printf '%s' "$APPMAKER_REF" | grep -Eq '^[0-9a-f]{40}$' || { echo 'APPMAKER_REFがimmutable commit SHAではありません。開発者向けoverrideを確認してください。' >&2; exit 1; }
repo="${APPMAKER_REPO_URL:-https://raw.githubusercontent.com/everyoneknows/android-ai-appmaker/$APPMAKER_REF}"
state="$HOME/.android-ai-appmaker"; base="$state/source"; mkdir -p "$base" "$state" "$HOME/.local/bin"
pidfile="$state/web.pid"
if [ -s "$pidfile" ]; then
  oldpid="$(cat "$pidfile" 2>/dev/null || true)"
  if printf '%s' "$oldpid" | grep -Eq '^[0-9]+$' && kill -0 "$oldpid" 2>/dev/null; then
    cmd="$(tr '\0' ' ' < "/proc/$oldpid/cmdline" 2>/dev/null || true)"
    case "$cmd" in *android-ai-appmaker*/web/server.py*) kill "$oldpid" 2>/dev/null || true; for _ in 1 2 3 4 5; do kill -0 "$oldpid" 2>/dev/null || break; sleep 1; done;; esac
  fi
  rm -f "$pidfile"
fi
files=(
  'scripts/termux-install.sh'
  'scripts/ai-adapter.sh'
  'builder/build-apk.sh'
  'bin/appmaker'
  'web/server.py'
  'web/index.html'
  'examples/calculator/AndroidManifest.xml'
  'examples/calculator/src/com/example/calculator/MainActivity.java'
)
part_cleanup() { find "$base" -type f -name '*.part' -delete 2>/dev/null || true; }
trap part_cleanup EXIT
for file in "${files[@]}"; do
  mkdir -p "$base/$(dirname -- "$file")"
  part="$base/$file.part"
  rm -f -- "$part"
  curl -fsSL --retry 3 "$repo/$file" -o "$part"
  test -s "$part"
  mv -f -- "$part" "$base/$file"
done
trap - EXIT
chmod +x "$base"/scripts/*.sh "$base"/builder/build-apk.sh "$base"/bin/appmaker
"$base/scripts/termux-install.sh"
ln -sfn "$base/bin/appmaker" "$HOME/.local/bin/appmaker"
echo '初回サンプル電卓を生成しています…'; APPMAKER_AI=none "$base/bin/appmaker" --sample
echo 'Web serverを起動しています…'; nohup python "$base/web/server.py" >"$state/web.log" 2>&1 & server_pid=$!; echo "$server_pid" > "$pidfile"
ready=false; for _ in $(seq 1 30); do kill -0 "$server_pid" 2>/dev/null || break; curl -fsS --max-time 2 http://127.0.0.1:8765/health >/dev/null 2>&1 && ready=true && break; sleep 1; done
if [ "$ready" != true ]; then echo "Web UIを起動できませんでした。ログ: $state/web.log" >&2; exit 1; fi
echo '電卓ができました！ APKは次の場所に保存されています:'; readlink -f "$HOME/android-ai-appmaker/out/latest/app.apk"; echo 'Web UI: http://127.0.0.1:8765/'
if command -v termux-open-url >/dev/null 2>&1; then termux-open-url http://127.0.0.1:8765/ >/dev/null 2>&1 || true; else echo 'ブラウザで上記URLを開いてください。'; fi
