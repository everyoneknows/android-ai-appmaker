#!/usr/bin/env bash
set -euo pipefail

# This is a network integration test, distinct from the fixture E2E test.
root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
content_sha="$(sed -n 's/^DEFAULT_APPMAKER_REF="\([0-9a-f]\{40\}\)"$/\1/p' "$root/setup.sh")"
[ "${#content_sha}" -eq 40 ] || { echo 'content SHA missing' >&2; exit 1; }
files=(
  scripts/termux-install.sh scripts/ai-adapter.sh builder/build-apk.sh bin/appmaker
  web/server.py web/index.html examples/calculator/AndroidManifest.xml
  examples/calculator/src/com/example/calculator/MainActivity.java
)
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
log="$tmp/results.tsv"
for file in "${files[@]}"; do
  url="https://raw.githubusercontent.com/everyoneknows/android-ai-appmaker/$content_sha/$file"
  body="$tmp/body"
  status="$(curl -sS --retry 3 --output "$body" --write-out '%{http_code}' "$url")"
  size="$(wc -c < "$body")"
  printf '%s\t%s\t%s\n' "$status" "$size" "$url" | tee -a "$log"
  [ "$status" = 200 ] && [ "$size" -gt 0 ] || { echo "production runtime取得失敗: $url" >&2; exit 1; }
done
printf 'production runtime URL test passed (%s files)\n' "${#files[@]}"
