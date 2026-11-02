#!/usr/bin/env bash
# Media player, Manual and Welcome: static checks (no GTK needed) plus the pure helper functions.
set -u
cd "$(dirname "$0")/.."
fail=0
chk() { if eval "$2"; then echo "ok: $1"; else echo "FAIL: $1"; fail=1; fi; }
chk "media compiles"                  "python3 -m py_compile bin/xlin-media bin/xlin-welcome bin/xlin-tools"
chk "media: full screen (F, F11, double-click)" "grep -q 'KEY_F11' bin/xlin-media && grep -q 'def toggle_fullscreen' bin/xlin-media && grep -q 'n == 2' bin/xlin-media"
chk "media: subtitles, audio tracks, equalizer, speed, repeat, shuffle" "grep -q 'def fill_subs' bin/xlin-media && grep -q 'def fill_audio' bin/xlin-media && grep -q 'def fill_eq' bin/xlin-media && grep -q 'SPEEDS' bin/xlin-media && grep -q 'def cycle_repeat' bin/xlin-media && grep -q 'shuffle' bin/xlin-media"
chk "media: GStreamer with a fallback" "grep -q 'class GstEngine' bin/xlin-media && grep -q 'class FileEngine' bin/xlin-media"
chk "media: normal window size, wrapping controls, playlist steps aside" "grep -q \"scaled(920)\" bin/xlin-media \chk "media: crash log"\chk "media: crash log" grep -q FlowBox bin/xlin-media \chk "media: crash log"\chk "media: crash log" grep -q _narrow bin/xlin-media"
chk "media: crash log"                "grep -q 'faulthandler.enable' bin/xlin-media"
chk "media: open starts after the window shows" "grep -q 'timeout_add(250' bin/xlin-media"
chk "codecs are installed by deps"    "grep -q 'gst-plugin-gtk4' scripts/deps.sh && grep -q 'gst-plugins-bad' scripts/deps.sh"
chk "media handles video/audio types" "grep -q 'video/quicktime' config/applications/dev.xlin.Media.desktop"
chk "Manual has an icon and a desktop entry" "[[ -f assets/icons/xlin-manual.svg ]] && grep -q 'Icon=xlin-manual' config/applications/dev.xlin.Manual.desktop && grep -q 'Exec=xlin manual' config/applications/dev.xlin.Manual.desktop"
chk "Manual has tabs"                 "python3 - <<'PY'
import re
s = open('bin/xlin-tools').read()
names = re.findall(r'^    \\(\"(\\w+)\", (?:\\[|None)', s[s.index('MANUAL_TABS'):], re.M)
assert names[:6] == ['Start', 'Desktop', 'Apps', 'Shortcuts', 'Help', 'About'], names
assert 'Xman' in s
assert 'Madhav Sharma with Team & Axion Co.' in s
PY"
chk "Welcome has more pages"         "python3 - <<'PY'
import re
s = open('bin/xlin-welcome').read()
b = s[s.index('self.builders = ['):s.index(']', s.index('self.builders = ['))]
assert len(re.findall(r'self\\.p_\\w+', b)) >= 9, b
for need in ('System font', 'Text size', 'Animations', 'Window transparency', 'Show the top bar', 'Night light', 'Open Settings'):
    assert need in s, need
PY"
chk "media helpers"                   "python3 - <<'PY'
import os, re, tempfile
src = open('bin/xlin-media').read()
ns = {'os': os, 're': re}
exec(src[src.index('def clock'):src.index('def read_state')], ns)
assert ns['clock'](75) == '1:15' and ns['clock'](3725) == '1:02:05' and ns['clock'](-3) == '0:00'
d = tempfile.mkdtemp()
for n in ('a.mp3', 'b.txt', 'c.MKV'):
    open(os.path.join(d, n), 'w').close()
exec(src[src.index('EXTS = '):src.index('SUB_EXTS')], ns)
exec(src[src.index('def media_files'):src.index('def to_uri')], ns)
got = sorted(os.path.basename(p) for p in ns['media_files']([d]))
assert got == ['a.mp3', 'c.MKV'], got
assert ns['media_files'](['https://x.test/s.mp3']) == ['https://x.test/s.mp3']
PY"
exit $fail
