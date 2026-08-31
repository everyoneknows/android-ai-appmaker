#!/usr/bin/env bash
set -euo pipefail

# This is deliberately an actual README curl | bash execution.  The curl shim
# only replaces the content endpoint after the immutable bootstrap has been
# fetched; it records every runtime URL and serves a local fixture for a fresh,
# network-independent Termux-equivalent run.
root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'if [ -s "$tmp/home/.android-ai-appmaker/web.pid" ]; then kill "$(cat "$tmp/home/.android-ai-appmaker/web.pid")" 2>/dev/null || true; fi; rm -rf "$tmp"' EXIT
mkdir -p "$tmp/home" "$tmp/bin" "$tmp/fixture"

files=(
  scripts/termux-install.sh scripts/ai-adapter.sh builder/build-apk.sh
  bin/appmaker web/server.py web/index.html
  examples/calculator/AndroidManifest.xml
  examples/calculator/src/com/example/calculator/MainActivity.java
)

# Regression guard for the Pixel failure: the old scalar+read loop consumes
# this space-separated value as exactly one filename/URL.  The E2E below must
# prove that the production array loop consumes the same logical list as eight
# independent requests.
legacy_files="${files[*]}"
legacy_count=0
while IFS= read -r legacy_file; do
  [ -n "$legacy_file" ] || continue
  legacy_count=$((legacy_count + 1))
  case "$legacy_file" in *' '*) :;; *) echo 'legacy regression fixture is not space-separated' >&2; exit 1;; esac
done <<< "$legacy_files"
[ "$legacy_count" -eq 1 ]

for file in "${files[@]}"; do
  mkdir -p "$tmp/fixture/$(dirname -- "$file")"
  cp "$root/$file" "$tmp/fixture/$file"
done

# Keep the E2E focused on setup's download/execute contract.  The real runtime
# files are still fetched one-by-one; these two commands avoid installing
# Android archives in the host test while preserving setup's complete flow.
cat > "$tmp/fixture/scripts/termux-install.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
mkdir -p "$HOME/android-ai-appmaker/out"
EOF
cat > "$tmp/fixture/bin/appmaker" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
mkdir -p "$HOME/android-ai-appmaker/out/latest"
printf 'fixture-apk\n' > "$HOME/android-ai-appmaker/out/latest/app.apk"
EOF
chmod +x "$tmp/fixture/scripts/termux-install.sh" "$tmp/fixture/bin/appmaker"

cat > "$tmp/bin/apt-get" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
cat > "$tmp/bin/python" <<'EOF'
#!/usr/bin/env bash
exec /usr/bin/python3 "$@"
EOF
cat > "$tmp/bin/curl" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
url=""
out=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    -o) out="$2"; shift 2;;
    --max-time|--retry) shift 2;;
    -*) shift;;
    *) url="$1"; shift;;
  esac
done
if [[ "$url" == https://github.com/everyoneknows/android-ai-appmaker/raw/*/setup.sh ]]; then
  exec /usr/bin/curl -fsSL "$url"
fi
if [[ "$url" == http://fixture.invalid/raw/* ]]; then
  file="${url#http://fixture.invalid/raw/}"
  printf '%s\n' "$file" >> "$CURL_LOG"
  [ -n "$out" ] || { echo "fixture curl missing -o: $url" >&2; exit 2; }
  cp "$FIXTURE/$file" "$out"
  exit 0
fi
exec /usr/bin/curl -fsS "$url"
EOF
chmod +x "$tmp/bin/apt-get" "$tmp/bin/python" "$tmp/bin/curl"

line="$(awk '/^curl -fsSL https:\/\/github\.com\/everyoneknows\/android-ai-appmaker\/raw\/[0-9a-f]{40}\/setup\.sh \| bash$/{print; exit}' "$root/README.md")"
[ -n "$line" ] || { echo 'README bootstrap line missing' >&2; exit 1; }
env -i HOME="$tmp/home" PREFIX=/data/data/com.termux/files/usr \
  PATH="$tmp/bin:/usr/bin:/bin" FIXTURE="$tmp/fixture" \
  CURL_LOG="$tmp/curl.log" APPMAKER_REPO_URL=http://fixture.invalid/raw \
  bash -c "$line"

[ "$(wc -l < "$tmp/curl.log")" -eq "${#files[@]}" ]
for file in "${files[@]}"; do
  grep -Fxq "$file" "$tmp/curl.log"
done
! grep -q '[[:space:]]' "$tmp/curl.log"
[ -s "$tmp/home/android-ai-appmaker/out/latest/app.apk" ]
/usr/bin/curl -fsS --max-time 2 http://127.0.0.1:8765/health >/dev/null
printf '%s\n' 'fresh README pipe E2E passed: every runtime file fetched individually'
