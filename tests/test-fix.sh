#!/usr/bin/env bash
# xlin fix repairs without a real system: stub sudo/pacman/systemctl, check each step runs and the update script is used.
set -u
cd "$(dirname "$0")/.."
ROOT="$PWD"; T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
export HOME="$T/home" XLIN_HOME="$T/home/.config/xlin" XDG_RUNTIME_DIR="$T/run"
mkdir -p "$XLIN_HOME/state" "$HOME/.config/hypr" "$T/bin" "$T/run" "$T/src" "$T/fake"
fail=0
chk() { if eval "$2"; then echo "ok: $1"; else echo "FAIL: $1"; fail=1; fi; }
for c in sudo pacman systemctl pacman-key; do printf '#!/bin/bash\necho "%s $*" >>"%s/calls"\nexit 0\n' "$c" "$T/fake" >"$T/bin/$c"; chmod +x "$T/bin/$c"; done
printf '#!/bin/bash\necho "$*" >"%s/update-args"\n' "$T" >"$T/src/update.sh"
export PATH="$T/bin:$PATH"
export XLIN_TEST=1
X="bash $ROOT/bin/xlin"

chk "fix is a command"               "grep -qE '^  fix\\|repair\\)' bin/xlin"
chk "pacman lock cleared, no process" "touch $T/lock; true"
echo "$T/src" >"$XLIN_HOME/state/source"
out="$($X fix 2>&1)"; rc=$?
chk "runs the installer"             "[[ -f $T/update-args ]]"
chk "installer gets --xlin-only"     "grep -q -- --xlin-only $T/update-args"
chk "steps are printed"              "grep -q 'Checking the result' <<<\"\$out\""
chk "services step"                  "grep -q 'services' <<<\"\$out\""
$X fix --full >/dev/null 2>&1
chk "--full passes through"          "grep -q -- --full $T/update-args"
rm -f "$XLIN_HOME/state/source"
out2="$($X fix 2>&1)"
chk "no source folder: says so"      "grep -q 'folder is not known' <<<\"\$out2\""
chk "SysDeb has the fix button"      "grep -q 'Fix everything' bin/xlin-debug"
chk "SysDeb compiles"                "python3 -m py_compile bin/xlin-debug"
chk "problem finder"                 "python3 - <<'PY'
import re
src = open('bin/xlin-debug').read()
ns = {'re': re}
exec(src[src.index('def problems'):src.index('def tail')], ns)
got = ns['problems']('  ok  a\n  MISSING  jq\n  NOT RUNNING  waybar\n  not active  bluetooth\n  ok b')
assert len(got) == 3, got
PY"
exit $fail
