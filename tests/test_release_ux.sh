#!/usr/bin/env bash
set -euo pipefail

root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
line="$(awk '/^curl -fsSL https:\/\/github\.com\/everyoneknows\/android-ai-appmaker\/raw\/[0-9a-f]{40}\/setup\.sh \| bash$/{print; exit}' "$root/README.md")"
[ -n "$line" ] || { echo 'READMEの初心者向け一行が要件を満たしません' >&2; exit 1; }
[ "$(printf '%s' "$line" | grep -o 'github\.com/everyoneknows/android-ai-appmaker' | wc -l)" -eq 1 ]
[ "$(printf '%s' "$line" | grep -oE '[0-9a-f]{40}' | wc -l)" -eq 1 ]
! printf '%s\n' "$line" | grep -Eq 'APPMAKER_REF=|raw\.githubusercontent\.com|main|\\$|\\`'
grep -q '^DEFAULT_APPMAKER_REF="[0-9a-f]\{40\}"$' "$root/setup.sh"
grep -q 'raw\.githubusercontent\.com/everyoneknows/android-ai-appmaker/\$APPMAKER_REF' "$root/setup.sh"
! grep -RInE 'github\.com/everyoneknows/android-ai-appmaker/raw/\$APPMAKER_REF|APPMAKER_REF=.*bash|APPMAKER_REF=.*README' "$root/README.md" "$root/docs" "$root/setup.sh"
printf '%s\n' 'release UX checks passed'
