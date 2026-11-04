#!/usr/bin/env bash
# The Wi-Fi, Bluetooth and Volume menus must never schedule refresh() as a repeating idle callback (it returns True
# while the window is open, so GLib would call it forever and the menu froze), and must read their state at start.
set -u
cd "$(dirname "$0")/.."
fail=0
chk() { if eval "$2"; then echo "ok: $1"; else echo "FAIL: $1"; fail=1; fi; }
chk "no idle_add(self.refresh)"        "! grep -n 'idle_add(self.refresh)' bin/xlin-tools"
chk "refresh_once always returns False" "python3 - <<'PY'
import re
s = open('bin/xlin-tools').read()
m = re.search(r'def refresh_once\(self.*?\n(?=    def )', s, re.S)
assert m and m.group(0).rstrip().endswith('return False'), 'refresh_once'
PY"
chk "reads run one at a time"          "grep -q 'def spawn_read' bin/xlin-tools"
chk "first read when the menu opens"   "[[ \$(grep -c 'GLib.idle_add(self.refresh_once)' bin/xlin-tools) -ge 4 ]]"
chk "Bluetooth can search and pair"    "grep -q 'def scan' bin/xlin-tools && grep -q 'def pair' bin/xlin-tools"
chk "nmcli signal not a number is ok"  "grep -q 'except ValueError' bin/xlin-tools"
chk "tools compiles"                   "python3 -m py_compile bin/xlin-tools"
exit $fail
