#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
ai="${APPMAKER_AI:-auto}"
case "$ai" in
  codex) command -v codex >/dev/null || { echo 'APPMAKER_AI=codexですがcodexがありません' >&2; exit 1; }; exec codex "$@";;
  none) exit 0;;
  auto) command -v codex >/dev/null && exec codex "$@" || exit 0;;
  *) echo 'APPMAKER_AIは auto/codex/none のいずれかです' >&2; exit 2;;
esac
