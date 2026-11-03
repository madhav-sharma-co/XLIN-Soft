#!/usr/bin/env bash
# xlin reset puts every saved choice back; the Wi-Fi, Bluetooth and Volume menus are reachable (no name clashes).
set -u
cd "$(dirname "$0")/.."
ROOT="$PWD"; T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
export HOME="$T/home" XLIN_HOME="$T/home/.config/xlin"
mkdir -p "$XLIN_HOME/state" "$HOME/bin" "$HOME/.config/hypr" "$HOME/.config/waybar"
fail=0
chk() { if eval "$2"; then echo "ok: $1"; else echo "FAIL: $1"; fail=1; fi; }
X="bash $ROOT/bin/xlin"

# no function is defined twice (the later one silently wins), and no case label is listed twice
chk "no duplicated functions"       "[[ -z \$(grep -oE '^[a-z_]+\\(\\)' bin/xlin | sort | uniq -d) ]]"
chk "no duplicated commands"        "python3 - <<'PY'
import re
s = open('bin/xlin').read()
body = s[s.index('case \"\${1:-help}\" in'):]
seen, dup = {}, []
for line in body.splitlines():
    m = re.match(r'^  ([a-z][a-z0-9|-]*)\\)', line)
    if m:
        for name in m.group(1).split('|'):
            if name in seen: dup.append(name)
            seen[name] = 1
assert not dup, dup
PY"

# the menu commands: no arguments = the window, with arguments = the command line tool
cat >"$HOME/bin/xlin-tools" <<'EOS'
#!/bin/bash
echo "$*" >>"$HOME/tools.log"
EOS
chmod +x "$HOME/bin/xlin-tools"; export PATH="$HOME/bin:$PATH"
mkdir -p "$XLIN_HOME/state"; touch "$XLIN_HOME/state/.gi_ok"
for m in wifi bluetooth volume; do
  rm -f "$HOME/tools.log"; $X $m >/dev/null 2>&1; sleep 0.3
  chk "xlin $m opens its menu"      "grep -qx '$m' $HOME/tools.log 2>/dev/null"
done

# reset
cd "$T"
for f in theme accent wallpaper animations sleep_minutes idle_minutes scroll statusbar_off bar_hidden brand_new_setting recent; do echo x >"$XLIN_HOME/state/$f"; done
echo "/src" >"$XLIN_HOME/state/source"; touch "$XLIN_HOME/state/.gi_ok"
echo '{"icons":[]}' >"$XLIN_HOME/desktop.json"
$X reset >/dev/null 2>&1; sleep 0.2
for f in theme accent wallpaper animations sleep_minutes idle_minutes scroll statusbar_off bar_hidden brand_new_setting recent; do
  chk "reset clears $f"             "[[ ! -s $XLIN_HOME/state/$f || \$(cat $XLIN_HOME/state/$f) != x ]]"
done
chk "the install record stays"      "[[ \$(cat $XLIN_HOME/state/source) == /src ]]"
chk "the stamp files stay"          "[[ -f $XLIN_HOME/state/.gi_ok ]]"
chk "desktop layout is cleared"     "[[ ! -f $XLIN_HOME/desktop.json ]]"
chk "scroll is normal again"        "grep -q 'natural_scroll = false' $HOME/.config/hypr/xlin-scroll.lua"
chk "animations are smooth again"   "[[ -f $HOME/.config/hypr/xlin-anim.lua ]] && ! grep -q 'enabled = false' $HOME/.config/hypr/xlin-anim.lua"
chk "window transparency default"   "grep -q 'active_opacity = 0.88' $HOME/.config/hypr/xlin-opacity.lua"
chk "welcome flag cleared"          "[[ ! -f $XLIN_HOME/state/welcomed ]]"
out="$($X reset 2>&1)"
chk "reset runs to the end"          "grep -q 'back to the defaults' <<<\"\$out\""
chk "About lists the feedback mails" "grep -q theaxion.co@gmail.com $ROOT/bin/xlin-tools && grep -q themadhavsharma.co@gmail.com $ROOT/bin/xlin-tools"
exit $fail
