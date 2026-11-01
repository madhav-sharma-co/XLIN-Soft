#!/usr/bin/env bash
# Scrolling: normal direction by default, natural scrolling is a switch; the wheel glides in every scroll area.
set -u
cd "$(dirname "$0")/.."
ROOT="$PWD"; T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
export HOME="$T/home" XLIN_HOME="$T/home/.config/xlin"
mkdir -p "$XLIN_HOME/state" "$HOME/.config/hypr"
fail=0
chk() { if eval "$2"; then echo "ok: $1"; else echo "FAIL: $1"; fail=1; fi; }
X="bash $ROOT/bin/xlin"
D="$HOME/.config/hypr"

chk "default is normal"            "$X scroll | grep -q 'scrolling: normal'"
$X scroll natural >/dev/null
chk "natural writes lua true"      "grep -q 'natural_scroll = true, touchpad = { natural_scroll = true }' $D/xlin-scroll.lua"
chk "natural writes conf true"     "grep -q 'natural_scroll = true' $D/xlin-scroll.conf && grep -c natural_scroll $D/xlin-scroll.conf | grep -q 2"
chk "natural is remembered"        "$X scroll | grep -q 'natural'"
$X scroll normal >/dev/null
chk "normal writes false"          "grep -q 'natural_scroll = false, touchpad = { natural_scroll = false }' $D/xlin-scroll.lua && ! grep -q true $D/xlin-scroll.conf"
chk "normal removes the state"     "[[ ! -f $XLIN_HOME/state/scroll ]]"
chk "bad value refused"            "! $X scroll sideways >/dev/null 2>&1"
chk "hypr configs load the file"   "grep -q 'xlin-scroll' config/hypr/xlin.lua && grep -q 'xlin-scroll.conf' config/hypr/xlin.conf"
chk "theme apply writes it too"    "sed -n '/^cmd_theme()/,/^}/p' bin/xlin | grep -q 'write_scroll' || grep -B3 -A1 'write_scroll \"\$(scroll_mode)\"' bin/xlin | grep -q write_anim"
chk "Settings has the switch"      "grep -q 'Natural scrolling' bin/xlin-settings"
chk "wheel glides everywhere"      "grep -q '_patch_scrolled_windows()' lib/xlin_ui.py && grep -q 'def smooth_wheel' lib/xlin_ui.py"
chk "python compiles"              "python3 -m py_compile lib/xlin_ui.py"
exit $fail
