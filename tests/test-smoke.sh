#!/usr/bin/env bash
# Builds every Xlin-soft app window with a stubbed GTK and runs the common actions (keys, menus, open, save, find ...).
# No display needed. Catches typos and wrong arguments in our own Python; GTK itself is not tested here.
set -u
cd "$(dirname "$0")/.."
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
export SMOKE_FILES="$T/files" HOME="$T/home"
mkdir -p "$SMOKE_FILES" "$HOME"
touch "$SMOKE_FILES/a.mp3" "$SMOKE_FILES/b.mkv" "$SMOKE_FILES/c.txt"
printf 'hello\nworld\n' >"$SMOKE_FILES/t.txt"
fail=0
run() { # app window [scenario]
  local out; out="$(SCEN="${3:+tests/smoke/$3.py}" timeout 60 python3 tests/smoke/gtk_stub.py "bin/$1" "$2" 2>&1)"
  if grep -q "constructed" <<<"$out" && { [[ -z "${3:-}" ]] || grep -q "scenario ok" <<<"$out"; }; then echo "ok: $1 $2 ${3:-}"
  else echo "FAIL: $1 $2 ${3:-}"; echo "$out" | tail -8; fail=1; fi
}
run xlin-media MediaWindow media
run xlin-edit EditWindow edit
run xlin-view ViewWindow view
run xlin-read ReadWindow read
run xlin-welcome WelcomeWindow welcome
run xlin-settings SettingsWindow settings
run xlin-debug DebugWindow debug
for w in ManualWindow PowerWindow SessionWindow MenuWindow; do run xlin-tools $w; done
for w in WifiWindow BluetoothWindow VolumeWindow; do run xlin-tools $w dropdown; done
run xlin-files FilesWindow
run xlin-store StoreWindow
run xlin-monitor MonitorWindow
exit $fail
