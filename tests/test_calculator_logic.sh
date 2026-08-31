#!/usr/bin/env bash
set -euo pipefail

# Static/logic regression guard. Android UI acceptance remains a separate
# real-device test and is intentionally not faked here.
root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
src="$root/examples/calculator/src/com/example/calculator/MainActivity.java"
grep -Fq '"⌫"' "$src"
grep -Fq 'input.substring(0,input.length()-1)' "$src"
grep -Fq 'input.equals("Error")' "$src"
grep -Fq 'String[] keys={"AC","C","⌫","÷","7","8","9","×","4","5","6","−","1","2","3","＋","0",".","="}' "$src"
grep -Fq 'if(fresh&& !pending.isEmpty())' "$src"
grep -Fq 'b==0' "$src"
printf '%s\n' 'calculator logic/layout regression checks passed (UI remains UNVERIFIED)'
