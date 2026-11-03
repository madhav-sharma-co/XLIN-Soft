#!/usr/bin/env bash
# Xedit and Xview: wired in everywhere (installer, launcher entries, window rules, defaults) + their pure helpers.
set -u
cd "$(dirname "$0")/.."
fail=0
chk() { if eval "$2"; then echo "ok: $1"; else echo "FAIL: $1"; fail=1; fi; }
for app in edit view; do
  chk "xlin-$app compiles"          "python3 -m py_compile bin/xlin-$app"
  chk "xlin-$app is installed"      "grep -q xlin-$app scripts/files.sh"
  chk "xlin-$app is in the doctor and uninstall lists" "grep -q 'xlin-$app[ ;]' bin/xlin && grep -q '/usr/local/bin/xlin-$app' bin/xlin"
  chk "xlin $app dispatches"        "grep -Eq '^  $app\\|x$app\\)' bin/xlin"
done
for pair in "Edit:xlin-edit" "View:xlin-view"; do
  n="${pair%%:*}"; icon="${pair##*:}"
  chk "$n: desktop entry and icon"  "grep -q 'Icon=$icon' config/applications/dev.xlin.$n.desktop && [[ -f assets/icons/$icon.svg ]]"
  chk "$n: window rules"            "grep -q 'xlin.\\.$n' config/hypr/xlin.conf && grep -q '\"$n\"' config/hypr/xlin.lua"
  chk "$n: listed in Settings -> Apps and Tools" "grep -q 'dev.xlin.$n' bin/xlin-settings"
done
chk "Xman icon is a plain X"        "grep -q 'M38 38L90 90M90 38L38 90' assets/icons/xlin-manual.svg"
chk "codecs/libs in deps"           "grep -q gtksourceview5 scripts/deps.sh"
chk "editor helpers"                "python3 - <<'PY'
src = open('bin/xlin-edit').read()
ns = {}
exec(src[src.index('def decode_text'):src.index('class Doc')], ns)
assert ns['decode_text'](b'hello') == ('hello', 'UTF-8')
assert ns['decode_text']('héllo'.encode('utf-8'))[0] == 'héllo'
assert ns['decode_text'](b'abc\\xe9')[1] == 'Latin-1'
assert ns['decode_text'](b'ab\\x00cd') == (None, None)
f = ns['find_in']
assert f('Hello hello', 'hello', 0) == 0 and f('Hello hello', 'hello', 1) == 6
assert f('Hello hello', 'hello', 7) == 0                      # wraps round
assert f('Hello hello', 'hello', 0, case=True) == 6
assert f('abc', 'x', 0) == -1 and f('abcabc', 'abc', 3, backwards=True) == 0
PY"
chk "image viewer helpers"          "python3 - <<'PY'
import os, re, tempfile
src = open('bin/xlin-view').read()
ns = {'os': os, 're': re}
exec(src[src.index('EXTS = '):src.index('SLIDE_SECONDS')], ns)
exec(src[src.index('def natural_key'):src.index('class ViewWindow')], ns)
d = tempfile.mkdtemp()
for n in ('img10.png', 'img2.PNG', 'notes.txt', '.hidden.png', 'a.jpg'):
    open(os.path.join(d, n), 'w').close()
got = [os.path.basename(p) for p in ns['images_in'](d)]
assert got == ['a.jpg', 'img2.PNG', 'img10.png'], got
assert ns['human'](512) == '512 B' and ns['human'](2048) == '2.0 KB'
PY"
exit $fail
