#!/usr/bin/env bash
set -euo pipefail

# Production network integration: fixed Google archives and their expected
# internal structure. This is separate from fixture setup tests.
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
cd "$tmp"
curl -fsSL --retry 3 -o platform.zip https://dl.google.com/android/repository/platform-35_r02.zip
printf '%s  %s\n' 0988cacad01b38a18a47bac14a0695f246bc76c1b06c0eeb8eb0dc825ab0c8e0 platform.zip | sha256sum -c - >/dev/null
unzip -Z1 platform.zip > platform.list
grep -Fxq android-35/android.jar platform.list
curl -fsSL --retry 3 -o build-tools.zip https://dl.google.com/android/repository/build-tools_r35_linux.zip
printf '%s  %s\n' bd3a4966912eb8b30ed0d00b0cda6b6543b949d5ffe00bea54c04c81e1561d88 build-tools.zip | sha256sum -c - >/dev/null
unzip -Z1 build-tools.zip > build-tools.list
for path in android-15/lib/d8.jar; do
  grep -Fxq "$path" build-tools.list
done
printf '%s\n' 'production Android archive checks passed'
