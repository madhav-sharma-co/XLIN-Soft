#!/usr/bin/env bash
# Status bar: clock switch, whole bar on/off, volume menu; Run Bar: pinning keeps it alive.
set -u
cd "$(dirname "$0")/.."
ROOT="$PWD"; T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
export HOME="$T/home" XLIN_HOME="$T/home/.config/xlin"
mkdir -p "$XLIN_HOME/state" "$HOME/bin" "$HOME/.config/waybar"
fail=0
chk() { if eval "$2"; then echo "ok: $1"; else echo "FAIL: $1"; fail=1; fi; }
X="bash $ROOT/bin/xlin"
cp config/waybar/config.jsonc "$HOME/.config/waybar/config.jsonc"; cp config/waybar/config.jsonc "$XLIN_HOME/waybar-base.jsonc"

# clock can be hidden from the bar
$X bar hide clock >/dev/null
chk "clock hidden"               "! grep -q '\"clock\"' <(grep modules- $HOME/.config/waybar/config.jsonc)"
$X bar show clock >/dev/null
chk "clock shown again"          "grep modules- $HOME/.config/waybar/config.jsonc | grep -q '\"clock\"'"
chk "Settings lists the clock"   "grep -q '(\"clock\", \"Time and date\"' bin/xlin-settings"

# whole status bar on / off (fake waybar that just sleeps)
cat >"$HOME/bin/waybar" <<'EOS'
#!/bin/bash
echo "[${LD_PRELOAD:-}]" >"$HOME/pre"
sleep 30
EOS
chmod +x "$HOME/bin/waybar"; export PATH="$HOME/bin:$PATH"
# the layer-shell preload is dropped by xlin itself (the Run Bar died after pinning)
rm -f "$HOME/pre"
if pgrep -x waybar >/dev/null; then echo "skip: a waybar (or its zombie) from an earlier run exists"; else
env LD_PRELOAD=/nonexistent/libgtk4-layer-shell.so.1 XLIN_START_REEXEC=1 bash "$ROOT/bin/xlin" statusbar on >/dev/null 2>&1; sleep 0.4
chk "xlin drops the preload (children never get it)" "[[ \$(cat $HOME/pre 2>/dev/null) == '[]' ]]"
fi
pkill -x waybar 2>/dev/null
$X statusbar off >/dev/null
chk "off: state file"            "[[ -f $XLIN_HOME/state/statusbar_off ]]"
chk "off: reported"              "$X statusbar | grep -q 'off'"
$X bar reset >/dev/null 2>&1; sleep 0.3
chk "bar reset also turns it on" "[[ ! -f $XLIN_HOME/state/statusbar_off ]]"
$X statusbar off >/dev/null
$X restart bar >/dev/null 2>&1; sleep 0.3
chk "restart does not bring it back while off" "! pgrep -x waybar >/dev/null"
$X statusbar on >/dev/null; sleep 0.3
chk "on: waybar runs"            "pgrep -x waybar >/dev/null"
pkill -x waybar 2>/dev/null
chk "Desktop settings has the switch" "grep -q 'Show status bar' bin/xlin-settings"
chk "bad value refused"          "! $X statusbar sideways >/dev/null 2>&1"

chk "pin checks the Run Bar is back" "sed -n '/^cmd_pin()/,/^}/p' bin/xlin | grep -q dock_verify"

# volume menu
chk "bar volume click opens the menu" "grep -A8 '\"pulseaudio\"' config/waybar/config.jsonc | grep -q '\"on-click\": \"xlin volume\"'"
chk "volume window rules"        "grep -q 'Volume' config/hypr/xlin.lua && grep -q 'Bluetooth|Volume' config/hypr/xlin.conf"
chk "sound outputs are parsed" "python3 - <<'PY'
import re, sys, types
src = open('bin/xlin-tools').read()
a = src.index('def read_sinks'); b = src.index('class VolumeWindow')
ns = {'re': re}
sample = '''PipeWire 'pipewire-0'
Audio
 ├─ Devices:
 │      46. Built-in Audio                      [alsa]
 │
 ├─ Sinks:
 │  *   47. Built-in Audio Analog Stereo        [vol: 0.50]
 │      52. HDMI / DisplayPort 1                [vol: 1.00]
 │
 ├─ Sink endpoints:
'''
ns['cmd_out'] = lambda *a, **k: (True, sample)
exec(src[a:b], ns)
got = ns['read_sinks']()
assert got == [('47', 'Built-in Audio Analog Stereo', True), ('52', 'HDMI / DisplayPort 1', False)], got
PY"
exit $fail
