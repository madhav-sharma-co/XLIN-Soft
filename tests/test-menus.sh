#!/usr/bin/env bash
# The Wi-Fi / Bluetooth menus, the Manual and the Welcome flag are wired up everywhere they must be.
set -u
cd "$(dirname "$0")/.."
fail=0
chk() { if ! eval "$2"; then echo "FAIL: $1"; fail=1; else echo "ok: $1"; fi; }

chk "bar: X opens the manual"        "grep -A5 '\"custom/xlin\"' config/waybar/config.jsonc | grep -q 'xlin manual'"
chk "bar: Wi-Fi opens the menu"      "grep -A12 '\"network\"' config/waybar/config.jsonc | grep -q '\"on-click\": \"xlin wifi\"'"
chk "bar: Bluetooth opens the menu"  "grep -A12 '\"bluetooth\"' config/waybar/config.jsonc | grep -q '\"on-click\": \"xlin bluetooth\"'"
for m in wifi bluetooth manual; do
  chk "xlin dispatches $m"           "grep -Eq '^  $m|^  ${m}\\|' bin/xlin || grep -Eq '^  (wifi\\|network|bluetooth\\|bt|manual\\|help-me)\\)' bin/xlin"
done
chk "xlin-tools knows the modes"     "grep -q 'EXTRA_IDS' bin/xlin-tools && grep -q 'ManualWindow' bin/xlin-tools"
chk "manual credits the makers"      "grep -q 'Madhav Sharma with Team & Axion Co' bin/xlin-tools"
chk "window rules (lua)"             "grep -q 'Wifi' config/hypr/xlin.lua && grep -q '\"Manual\"' config/hypr/xlin.lua"
chk "window rules (conf)"            "grep -q 'Wifi|Bluetooth' config/hypr/xlin.conf && grep -q 'xlin.*Manual' config/hypr/xlin.conf"
chk "install clears welcomed"        "grep -q 'rm -f \"\$XLIN_HOME/state/welcomed\"' install.sh"
chk "reset clears welcomed + shows"  "sed -n '/^cmd_reset()/,/^}/p' bin/xlin | grep -q 'welcomed' && sed -n '/^cmd_reset()/,/^}/p' bin/xlin | grep -q 'cmd_welcome --first'"
chk "control panel button order" "python3 -c \"import json;a=[x['label'].split('  ',1)[1] for x in json.load(open('config/swaync/config.json'))['widget-config']['buttons-grid']['actions']];assert a==['Wi-Fi','Bluetooth','Airplane','Do not disturb','Dark mode','Night light','Settings','Reload'],a\""
chk "python compiles"                "python3 -m py_compile bin/xlin-tools"
chk "bash syntax"                    "bash -n bin/xlin"
exit $fail
