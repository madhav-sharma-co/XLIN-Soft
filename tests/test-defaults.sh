#!/usr/bin/env bash
# Default apps: Xlin-soft's own are the defaults, Settings has an Apps and Tools tab, General has the battery mode.
set -u
cd "$(dirname "$0")/.."
ROOT="$PWD"; T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
export HOME="$T/home" XLIN_HOME="$T/home/.config/xlin"
mkdir -p "$XLIN_HOME/state" "$HOME/bin"
fail=0
chk() { if eval "$2"; then echo "ok: $1"; else echo "FAIL: $1"; fail=1; fi; }

# a fake xdg-mime that records what is set
cat >"$HOME/bin/xdg-mime" <<'EOS'
#!/usr/bin/env bash
[[ "$1" == default ]] && echo "$3=$2" >>"$HOME/mime.log"
[[ "$1" == query ]] && grep "^$3=" "$HOME/mime.log" 2>/dev/null | tail -1 | cut -d= -f2
exit 0
EOS
chmod +x "$HOME/bin/xdg-mime"; export PATH="$HOME/bin:$PATH"
X="bash $ROOT/bin/xlin"

echo kitty >"$XLIN_HOME/state/terminal"
$X defaults reset >/dev/null
chk "reset: Files is the folder app"      "grep -q 'inode/directory=dev.xlin.Files.desktop' $HOME/mime.log"
chk "reset: Media plays audio and video"  "grep -q 'audio/mpeg=dev.xlin.Media.desktop' $HOME/mime.log && grep -q 'video/webm=dev.xlin.Media.desktop' $HOME/mime.log"
chk "reset: Xedit edits text, Xview shows pictures" "grep -q 'text/plain=dev.xlin.Edit.desktop' $HOME/mime.log && grep -q 'application/json=dev.xlin.Edit.desktop' $HOME/mime.log && grep -q 'image/png=dev.xlin.View.desktop' $HOME/mime.log"
chk "reset: Xlin-soft Terminal again"     "[[ ! -f $XLIN_HOME/state/terminal ]]"
$X defaults set browser firefox >/dev/null
chk "set browser covers http, https, html" "grep -q 'x-scheme-handler/http=firefox.desktop' $HOME/mime.log && grep -q 'x-scheme-handler/https=firefox.desktop' $HOME/mime.log && grep -q 'text/html=firefox.desktop' $HOME/mime.log"
chk "unknown kind is refused"             "! $X defaults set toaster foo.desktop >/dev/null 2>&1"
chk "terminal that is not installed is refused" "! $X terminal use no-such-terminal-xyz >/dev/null 2>&1"
chk "terminal back to xlin"               "$X terminal use xlin >/dev/null && [[ ! -f $XLIN_HOME/state/terminal ]]"
chk "install makes Xlin-soft the defaults" "grep -q 'xlin defaults reset' $ROOT/install.sh"
chk "General has no terminal row"         "! sed -n '/^def general_page/,/^class ConnectivityPage/p' $ROOT/bin/xlin-settings | grep -q '\"Terminal\"'"
chk "General has the battery mode"        "sed -n '/^def general_page/,/^class ConnectivityPage/p' $ROOT/bin/xlin-settings | grep -q 'battery_rows'"
chk "Apps and Tools tab exists"           "grep -q '(\"apps\", \"Apps and Tools\"' $ROOT/bin/xlin-settings"
chk "General first, About last"           "python3 - <<PY
import re
s=open('$ROOT/bin/xlin-settings').read()
keys=re.findall(r'^    \\(\"(\\w+)\", \"[^\"]+\", \"[\\w-]+\"\\),\$', s[s.index('PAGES = ['):s.index('ALIASES')], re.M)
assert keys[0]=='general' and keys[-1]=='about', keys
PY"
exit $fail
