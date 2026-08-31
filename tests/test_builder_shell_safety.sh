#!/usr/bin/env bash
set -euo pipefail

root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
sdk="$tmp/sdk"; tools="$sdk/build-tools/35.0.0"; src="$tmp/src"; out="$tmp/out.apk"; jdk="$tmp/jdk"
mkdir -p "$tools/lib" "$sdk/platforms/android-35" "$src" "$jdk/bin"
printf 'jar fixture' > "$tools/lib/d8.jar"; printf 'jar fixture' > "$tools/lib/apksigner.jar"
printf 'android jar fixture' > "$sdk/platforms/android-35/android.jar"
printf '<manifest/>\n' > "$src/AndroidManifest.xml"
mkdir -p "$src/src"; printf 'class Main {}\n' > "$src/src/Main.java"
cat > "$tools/aapt2" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
while [ "$#" -gt 0 ]; do
  if [ "$1" = -o ]; then
    item="$(mktemp)"; printf resource > "$item"; zip -q "$2" "$item"; rm -f "$item"; exit 0
  fi
  shift
done
EOF
cat > "$tools/zipalign" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cp "${@: -2:1}" "${@: -1}"
EOF
chmod +x "$tools/aapt2" "$tools/zipalign"
cat > "$tmp/javac" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
while [ "$#" -gt 0 ]; do [ "$1" = -d ] && { out="$2"; break; }; shift; done
mkdir -p "$out"; printf class > "$out/classes with space.class"
EOF
cat > "$jdk/bin/java" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [ "${1:-}" = -cp ]; then
  printf '%s\n' "$@" > "$D8_ARGS_LOG"
  while [ "$#" -gt 0 ]; do [ "$1" = --output ] && { mkdir -p "$2"; printf dex > "$2/classes.dex"; exit 0; }; shift; done
fi
if [ "${1:-}" = -jar ]; then
  if [ "${3:-}" = sign ]; then
    input="${@: -1}"; while [ "$#" -gt 0 ]; do [ "$1" = --out ] && { cp "$input" "$2"; exit 0; }; shift; done
  fi
fi
EOF
cat > "$jdk/bin/keytool" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
while [ "$#" -gt 0 ]; do case "$1" in -keystore) : > "$2"; shift 2;; *) shift;; esac; done
EOF
mv "$tmp/javac" "$jdk/bin/javac"; chmod +x "$jdk/bin"/*
cat > "$tmp/java" <<'EOF'
#!/usr/bin/env bash
echo 'generic java 21 must not be used' >&2; exit 99
EOF
cat > "$tmp/javac" <<'EOF'
#!/usr/bin/env bash
echo 'generic javac 21 must not be used' >&2; exit 99
EOF
chmod +x "$tmp/java" "$tmp/javac"
ANDROID_SDK_ROOT="$sdk" JDK25_ROOT="$jdk" AAPT2="$tools/aapt2" APKSIGNER_JAR="$tools/lib/apksigner.jar" ZIPALIGN="$tools/zipalign" D8_ARGS_LOG="$tmp/d8.args" PATH="$tmp:$tools:$PATH" \
  HOME="$tmp/home" "$root/builder/build-apk.sh" "$src" "$out"
[ "$(grep -Fc 'classes with space.class' "$tmp/d8.args")" -eq 1 ]
test -s "$out"
printf '%s\n' 'builder shell safety test passed: class path with spaces stayed one argument'
