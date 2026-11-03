#!/usr/bin/env bash
# The installer can never hang: slow helpers are stopped, and the last step restarts Xlin-soft by itself.
set -u
cd "$(dirname "$0")/.."
ROOT="$PWD"; T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
fail=0
chk() { if eval "$2"; then echo "ok: $1"; else echo "FAIL: $1"; fail=1; fi; }

chk "install.sh restarts at the end"   "grep -q '^xlin_finish' install.sh && grep -q 'timeout 120 /usr/local/bin/xlin theme' install.sh"
chk "update.sh restarts at the end"    "grep -q '^xlin_finish' update.sh"
chk "install steps take no input"      "grep -q 'xlin theme light </dev/null' install.sh"

# wait_bounded: a job that would run for 30 s is stopped after 1 s
source <(sed -n '/^wait_bounded() {/,/^}/p' bin/xlin)
sleep 30 & p=$!
start=$SECONDS
wait_bounded 1 "$p"
chk "a stuck job is stopped in time"   "(( SECONDS - start < 5 )) && ! kill -0 $p 2>/dev/null"
sleep 0.2 & q=$!
start=$SECONDS; wait_bounded 5 "$q"
chk "a quick job does not wait for the limit" "(( SECONDS - start < 3 ))"

# xlin_find_hyprland: finds a running Hyprland from a terminal that has no signature
source scripts/files.sh
mkdir -p "$T/run/hypr/abc123_1_2"
python3 - "$T/run/hypr/abc123_1_2/.socket.sock" <<'PY'
import socket, sys
s = socket.socket(socket.AF_UNIX); s.bind(sys.argv[1])
PY
touch "$T/run/wayland-1"
( unset HYPRLAND_INSTANCE_SIGNATURE WAYLAND_DISPLAY; export XDG_RUNTIME_DIR="$T/run"
  xlin_find_hyprland && [[ "$HYPRLAND_INSTANCE_SIGNATURE" == abc123_1_2 && "$WAYLAND_DISPLAY" == wayland-1 ]] ) \
  && echo "ok: Hyprland found without a signature" || { echo "FAIL: Hyprland found without a signature"; fail=1; }
( unset HYPRLAND_INSTANCE_SIGNATURE; export XDG_RUNTIME_DIR="$T/empty"; ! xlin_find_hyprland ) \
  && echo "ok: no Hyprland: reports it" || { echo "FAIL: no Hyprland: reports it"; fail=1; }

# xlin_finish: restarts when Hyprland is there, tells you what to do when it is not
mkdir -p "$T/bin"
printf '#!/bin/bash\necho "restart ran" >>"%s/calls"\n' "$T" >"$T/bin/xlin-fake"; chmod +x "$T/bin/xlin-fake"
printf '#!/bin/bash\nexit 0\n' >"$T/bin/hyprctl"; chmod +x "$T/bin/hyprctl"
out="$(unset HYPRLAND_INSTANCE_SIGNATURE; export XDG_RUNTIME_DIR="$T/empty2" PATH="$T/bin:$PATH"; xlin_finish 2>&1)"
chk "not running: says what to do"     "grep -q 'then run: xlin restart' <<<\"\$out\""
exit $fail
