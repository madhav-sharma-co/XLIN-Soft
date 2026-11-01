#!/usr/bin/env bash
# xlin wallpapers: six built-in gradients, user wallpapers can be added and removed, built-ins are protected.
set -u
cd "$(dirname "$0")/.."
ROOT="$PWD"; T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
export HOME="$T/home" XLIN_HOME="$T/home/.config/xlin"
mkdir -p "$XLIN_HOME/state" "$XLIN_HOME/wallpapers"
cp assets/wallpapers/*.jpg "$XLIN_HOME/wallpapers/"
fail=0
chk() { if eval "$2"; then echo "ok: $1"; else echo "FAIL: $1"; fail=1; fi; }
X="bash $ROOT/bin/xlin"

chk "exactly six built-in wallpapers"  "[[ \$(ls assets/wallpapers | wc -l) -eq 6 ]]"
for n in light dark dark-blue light-blue dark-green light-pink; do chk "built-in $n exists" "[[ -s assets/wallpapers/xlin-$n.jpg ]]"; done
chk "list shows six"                   "[[ \$($X wallpapers list | wc -l) -eq 6 ]]"
chk "path is the hidden folder"        "[[ \$($X wallpapers path) == $XLIN_HOME/wallpapers ]]"
cp assets/wallpapers/xlin-dark.jpg "$T/mine.jpg"
chk "add a wallpaper"                  "$X wallpapers add $T/mine.jpg >/dev/null && [[ -f $XLIN_HOME/wallpapers/mine.jpg ]]"
chk "list shows seven"                 "[[ \$($X wallpapers list | wc -l) -eq 7 ]]"
chk "a non-picture is refused"         "echo hi >$T/x.txt; ! $X wallpapers add $T/x.txt >/dev/null"
cp assets/wallpapers/xlin-light.jpg "$T/xlin-light.jpg"; echo junk >>"$T/xlin-light.jpg"
chk "built-in name is never replaced"  "$X wallpapers add $T/xlin-light.jpg >/dev/null; cmp -s assets/wallpapers/xlin-light.jpg $XLIN_HOME/wallpapers/xlin-light.jpg"
chk "built-in cannot be removed"       "! $X wallpapers remove xlin-dark.jpg >/dev/null && [[ -f $XLIN_HOME/wallpapers/xlin-dark.jpg ]]"
chk "own wallpaper can be removed"     "$X wallpapers remove mine.jpg >/dev/null && [[ ! -f $XLIN_HOME/wallpapers/mine.jpg ]]"
chk "path tricks are harmless"         "! $X wallpapers remove ../../state >/dev/null"
chk "update.sh clears the old built-ins" "grep -q 'dawn mist lagoon' update.sh"
exit $fail
