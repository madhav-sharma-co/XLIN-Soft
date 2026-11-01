#!/usr/bin/env bash
# Apps opened from the Launcher or the desktop (Firefox, Claude, ...) must not inherit the layer-shell preload.
set -u
cd "$(dirname "$0")/.."
fail=0
chk() { if eval "$2"; then echo "ok: $1"; else echo "FAIL: $1"; fail=1; fi; }
for pair in "bin/xlin-start:XLIN_START_REEXEC" "bin/xlin-desktop:XLIN_DESKTOP_REEXEC"; do
  f="${pair%%:*}"; var="${pair##*:}"
  got="$(env LD_PRELOAD=/usr/lib/libgtk4-layer-shell.so.1.0.0 "$var"=1 python3 - "$f" "$var" 2>/dev/null <<'PY'
import os, re, sys, glob
src = open(sys.argv[1]).read()
block = src[src.index("if not os.environ.get("):src.index("import gi")]
exec(block)
print(repr(os.environ.get("LD_PRELOAD")), repr(os.environ.get(sys.argv[2])))
PY
)"
  chk "$f drops the preload"  "[[ \"$got\" == \"None None\" ]]"
  got="$(env LD_PRELOAD=/usr/lib/libgtk4-layer-shell.so.1:/opt/mine.so "$var"=1 python3 - "$f" "$var" 2>/dev/null <<'PY'
import os, sys, glob
src = open(sys.argv[1]).read()
exec(src[src.index("if not os.environ.get("):src.index("import gi")])
print(os.environ.get("LD_PRELOAD"))
PY
)"
  chk "$f keeps someone else's preload" "[[ \"$got\" == /opt/mine.so ]]"
done
chk "xlin launch-app strips it too" "grep -q 'env -u LD_PRELOAD' bin/xlin"
exit $fail
