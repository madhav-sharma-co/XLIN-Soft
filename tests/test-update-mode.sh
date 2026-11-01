#!/usr/bin/env bash
# Update asks: full system update (y) or only Xlin-soft (n).
set -u
cd "$(dirname "$0")/.."
source scripts/update-mode.sh
fail=0
chk() { if [[ "$2" == "$3" ]]; then echo "ok: $1"; else echo "FAIL: $1 (got '$2', want '$3')"; fail=1; fi; }
unset XLIN_NO_UPGRADE XLIN_FULL_UPGRADE
chk "--full"                    "$(xlin_update_mode --full </dev/null)" full
chk "--xlin-only"               "$(xlin_update_mode --xlin-only </dev/null)" xlin
chk "no terminal: Xlin-soft only" "$(xlin_update_mode </dev/null)" xlin
chk "XLIN_NO_UPGRADE=1"         "$(XLIN_NO_UPGRADE=1 xlin_update_mode </dev/null)" xlin
chk "XLIN_FULL_UPGRADE=1"       "$(XLIN_FULL_UPGRADE=1 xlin_update_mode </dev/null)" full
chk "flag beats environment"    "$(XLIN_FULL_UPGRADE=1 xlin_update_mode --xlin-only </dev/null)" xlin
if command -v script >/dev/null; then       # a real terminal: answer the question
  for pair in "y:full" "Y:full" "yes:full" "n:xlin" ":xlin" "x:xlin"; do
    ans="${pair%%:*}"; want="${pair##*:}"
    got="$(printf '%s\n' "$ans" | script -qec "bash -c 'source scripts/update-mode.sh; xlin_update_mode' 2>/dev/null" /dev/null | tr -d '\r' | tail -1)"
    chk "asked, answer '$ans'"  "$got" "$want"
  done
fi
chk "update.sh asks first"      "$(grep -c 'xlin_update_mode' update.sh)" 1
chk "xlin update passes the flags on" "$(grep -c 'update.sh \"\$@\"' bin/xlin)" 1
chk "scroll bar css"            "$(grep -c '^scrollbar slider {' templates/tools.css.tpl)" 1
exit $fail
