#!/usr/bin/env bash
# A hidden window brought back by the Run Bar becomes a normal window again, and the cover is put away.
set -u
cd "$(dirname "$0")/.."
ROOT="$PWD"; T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
export HOME="$T/home" XLIN_HOME="$T/home/.config/xlin"
mkdir -p "$XLIN_HOME/state" "$HOME/bin"
fail=0
chk() { if eval "$2"; then echo "ok: $1"; else echo "FAIL: $1"; fail=1; fi; }

# fake hyprctl: one monitor on workspace 3, the hidden-windows space is shown, window 0xabc is in it and focused
cat >"$HOME/bin/hyprctl" <<'EOS'
#!/usr/bin/env bash
echo "$*" >>"$HOME/calls"
case "$1 ${2:-}" in
  "monitors -j")
    if [[ -f $HOME/closed ]]; then sp=""; else sp="special:xlin-hidden"; fi
    echo "[{\"focused\":true,\"activeWorkspace\":{\"id\":3},\"specialWorkspace\":{\"name\":\"$sp\"}}]" ;;
  "activewindow -j") echo '{"address":"0xabc","workspace":{"name":"special:xlin-hidden"}}' ;;
  "clients -j") echo '[{"address":"0xabc","workspace":{"name":"special:xlin-hidden"},"focusHistoryID":0},{"address":"0xdef","workspace":{"name":"special:xlin-hidden"},"focusHistoryID":1}]' ;;
  "dispatch togglespecialworkspace") touch "$HOME/closed" ;;
esac
exit 0
EOS
chmod +x "$HOME/bin/hyprctl"; export PATH="$HOME/bin:$PATH"
X="bash $ROOT/bin/xlin"

$X restore-shown
chk "the window moves to the current workspace" "grep -q 'dispatch movetoworkspacesilent 3,address:0xabc' $HOME/calls"
chk "only that window moves"                    "! grep -q '0xdef' $HOME/calls"
chk "the cover is put away"                     "grep -q 'dispatch togglespecialworkspace xlin-hidden' $HOME/calls"
chk "the window is focused"                     "grep -q 'dispatch focuswindow address:0xabc' $HOME/calls"

rm -f "$HOME/calls" "$HOME/closed"; touch "$HOME/closed"      # nothing shown: does nothing
$X restore-shown
chk "nothing shown: no move"                    "! grep -q movetoworkspacesilent $HOME/calls"

chk "dock watch calls it"                       "grep -q 'xlin restore-shown' bin/xlin-dock-watch"
chk "hide button handles a stuck window"        "grep -q '_in_hidden_cover' lib/xlin_ui.py"
exit $fail
