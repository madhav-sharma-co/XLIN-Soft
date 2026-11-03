#!/usr/bin/env python3
"""Writes the Xlin-soft app icons (rounded squares with a soft gradient) to assets/icons.
No dependencies. Run: python3 scripts/make-icons.py"""
import os

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets", "icons")
FONT = "Inter, 'SF Pro Display', 'Helvetica Neue', Arial, sans-serif"


def icon(name, c1, c2, body, extra_defs=""):
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
<defs>
<linearGradient id="g" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{c1}"/><stop offset="1" stop-color="{c2}"/></linearGradient>
<linearGradient id="gloss" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#fff" stop-opacity=".28"/><stop offset=".55" stop-color="#fff" stop-opacity="0"/></linearGradient>
<filter id="sh" x="-20%" y="-20%" width="140%" height="150%"><feDropShadow dx="0" dy="2" stdDeviation="2.2" flood-color="#000" flood-opacity=".28"/></filter>
{extra_defs}</defs>
<rect x="6" y="6" width="116" height="116" rx="27" fill="url(#g)"/>
<rect x="6" y="6" width="116" height="116" rx="27" fill="url(#gloss)"/>
<rect x="6.5" y="6.5" width="115" height="115" rx="26.5" fill="none" stroke="#fff" stroke-opacity=".35"/>
<g filter="url(#sh)">{body}</g>
</svg>
'''


def gear():
    teeth = '<circle cx="64" cy="64" r="34" fill="none" stroke="#fff" stroke-width="13" stroke-dasharray="13.35 13.35" stroke-dashoffset="6.7"/>'
    return teeth + '<circle cx="64" cy="64" r="28" fill="#fff"/><circle cx="64" cy="64" r="12" fill="#6b7587"/>'


def notes():
    lines = "".join(f'<rect x="38" y="{y}" width="{w}" height="5" rx="2.5" fill="#d9b65a"/>' for y, w in ((60, 52), (73, 52), (86, 34)))
    return ('<rect x="30" y="22" width="68" height="86" rx="10" fill="#fff"/>'
            '<rect x="30" y="22" width="68" height="22" rx="10" fill="#ffe08a"/><rect x="30" y="34" width="68" height="10" fill="#ffe08a"/>'
            + lines)


def calc():
    keys = ""
    for r in range(4):
        for col in range(4):
            x, y = 28 + col * 18.5, 54 + r * 17
            fill = "#ff9f0a" if col == 3 else ("#6b6b72" if r == 0 and col < 3 else "#4a4a50")
            keys += f'<rect x="{x}" y="{y}" width="15" height="13" rx="4.5" fill="{fill}"/>'
    return '<rect x="28" y="24" width="72" height="24" rx="7" fill="#26262a"/><text x="94" y="43" text-anchor="end" font-family="' + FONT + '" font-size="17" font-weight="600" fill="#fff">26</text>' + keys


def calendar():
    return ('<rect x="24" y="22" width="80" height="86" rx="13" fill="#fff"/>'
            '<path d="M24 35a13 13 0 0 1 13-13h54a13 13 0 0 1 13 13v9H24z" fill="#ff453a"/>'
            '<rect x="42" y="14" width="6" height="16" rx="3" fill="#fff"/><rect x="80" y="14" width="6" height="16" rx="3" fill="#fff"/>'
            '<text x="64" y="94" text-anchor="middle" font-family="' + FONT + '" font-size="40" font-weight="600" fill="#1c1c1e">26</text>')


def folder():
    return ('<path d="M22 44a9 9 0 0 1 9-9h20l9 10h37a9 9 0 0 1 9 9v38a9 9 0 0 1-9 9H31a9 9 0 0 1-9-9z" fill="#fff" fill-opacity=".55"/>'
            '<path d="M22 56a9 9 0 0 1 9-9h66a9 9 0 0 1 9 9v35a9 9 0 0 1-9 9H31a9 9 0 0 1-9-9z" fill="#fff"/>')


def tools():
    sq = ""
    for i, (x, y) in enumerate(((28, 28), (70, 28), (28, 70), (70, 70))):
        sq += f'<rect x="{x}" y="{y}" width="30" height="30" rx="9" fill="#fff" fill-opacity="{1 if i != 3 else .55}"/>'
    return sq


def sparkle():
    star = lambda cx, cy, r: (f'<path d="M{cx} {cy-r}Q{cx} {cy} {cx+r} {cy}Q{cx} {cy} {cx} {cy+r}Q{cx} {cy} {cx-r} {cy}Q{cx} {cy} {cx} {cy-r}z" fill="#fff"/>')
    return star(60, 66, 34) + star(94, 36, 14) + star(96, 88, 10)


def monitor():
    return ('<rect x="24" y="30" width="80" height="62" rx="10" fill="#fff" fill-opacity=".95"/>'
            '<path d="M32 74l16-18 12 10 18-26 10 14" fill="none" stroke="#1fa971" stroke-width="7" stroke-linecap="round" stroke-linejoin="round"/>'
            '<rect x="48" y="98" width="32" height="7" rx="3.5" fill="#fff"/>')


def terminal():
    return ('<rect x="20" y="28" width="88" height="72" rx="12" fill="#101216"/>'
            '<circle cx="34" cy="41" r="3.2" fill="#ff5f57"/><circle cx="45" cy="41" r="3.2" fill="#febc2e"/><circle cx="56" cy="41" r="3.2" fill="#28c840"/>'
            '<path d="M35 62l14 10-14 10" fill="none" stroke="#5ee0a0" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>'
            '<rect x="58" y="80" width="26" height="6" rx="3" fill="#fff" fill-opacity=".85"/>')


def screenshot():
    corner = lambda d: f'<path d="{d}" fill="none" stroke="#fff" stroke-width="8" stroke-linecap="round" stroke-linejoin="round"/>'
    return (corner("M30 52V38a8 8 0 0 1 8-8h14") + corner("M76 30h14a8 8 0 0 1 8 8v14")
            + corner("M98 76v14a8 8 0 0 1-8 8H76") + corner("M52 98H38a8 8 0 0 1-8-8V76")
            + '<circle cx="64" cy="64" r="9" fill="#fff"/>')


def power(color):
    return (f'<path d="M64 26v36" stroke="#fff" stroke-width="10" stroke-linecap="round" fill="none"/>'
            f'<path d="M44 40a34 34 0 1 0 40 0" stroke="#fff" stroke-width="10" stroke-linecap="round" fill="none"/>')


def store():
    return ('<path d="M34 50h60l-5 46a8 8 0 0 1-8 7H47a8 8 0 0 1-8-7z" fill="#fff"/>'
            '<path d="M50 50v-8a14 14 0 0 1 28 0v8" fill="none" stroke="#fff" stroke-width="7" stroke-linecap="round"/>'
            '<path d="M52 70l12 12 14-18" fill="none" stroke="#0a84ff" stroke-width="7" stroke-linecap="round" stroke-linejoin="round"/>')


def media():
    return ('<circle cx="64" cy="64" r="36" fill="#fff" fill-opacity=".95"/>'
            '<path d="M54 46l30 18-30 18z" fill="#e5484d"/>')


def xsign():
    return ('<path d="M38 38L90 90M90 38L38 90" stroke="#fff" stroke-width="15" stroke-linecap="round" fill="none"/>')


def pencil():
    return ('<path d="M34 94l4-18 38-38 14 14-38 38z" fill="#fff"/>'
            '<path d="M80 34l8-8a6 6 0 0 1 8.5 0l5.5 5.5a6 6 0 0 1 0 8.5l-8 8z" fill="#fff" fill-opacity=".8"/>'
            '<path d="M34 94l4-18 14 14z" fill="#2f9e5f"/>')


def picture():
    return ('<rect x="22" y="30" width="84" height="68" rx="10" fill="#fff"/>'
            '<circle cx="46" cy="52" r="8" fill="#f5a623"/>'
            '<path d="M26 92l26-28 18 18 12-12 24 22z" fill="#2fa6b8"/>')


def document():
    return ('<path d="M36 22h40l20 20v62a6 6 0 0 1-6 6H36a6 6 0 0 1-6-6V28a6 6 0 0 1 6-6z" fill="#fff"/>'
            '<path d="M76 22v14a6 6 0 0 0 6 6h14z" fill="#fff" fill-opacity=".7"/>'
            '<path d="M42 58h44M42 72h44M42 86h28" stroke="#e5484d" stroke-width="6" stroke-linecap="round"/>')


def debug():
    return ('<ellipse cx="64" cy="70" rx="22" ry="28" fill="#fff"/>'
            '<circle cx="64" cy="40" r="12" fill="#fff"/>'
            '<path d="M40 56l-14-8M88 56l14-8M40 74H24M88 74h16M42 92l-12 10M86 92l12 10" stroke="#fff" stroke-width="6" stroke-linecap="round"/>'
            '<path d="M64 48v44" stroke="#e08a00" stroke-width="5"/>')


def clock():
    return ('<circle cx="64" cy="64" r="38" fill="#fff"/>'
            '<path d="M64 38v28l18 12" fill="none" stroke="#1c1c1e" stroke-width="7" stroke-linecap="round" stroke-linejoin="round"/>'
            '<circle cx="64" cy="64" r="4.5" fill="#ff9f0a"/>')


ICONS = {
    "xlin-settings": ("#a3adbf", "#626d82", gear()),
    "xlin-notes": ("#ffd95e", "#ffb300", notes()),
    "xlin-calculator": ("#4b4b52", "#1c1c1e", calc()),
    "xlin-calendar": ("#f5f6fa", "#d9dce6", calendar()),
    "xlin-files": ("#5ac8fa", "#0a7cff", folder()),
    "xlin-tools": ("#bf7bff", "#5a57e0", tools()),
    "xlin-manual": ("#7fd6ff", "#3b6df0", xsign()),
    "xlin-edit": ("#6be39a", "#1f9d5f", pencil()),
    "xlin-read": ("#ffb199", "#e5484d", document()),
    "xlin-view": ("#7dd3fc", "#2563eb", picture()),
    "xlin-welcome": ("#ff8fb1", "#ff8a3d", sparkle()),
    "xlin-monitor": ("#5ee0a0", "#16a05f", monitor()),
    "xlin-terminal": ("#5b6272", "#23262f", terminal()),
    "xlin-screenshot": ("#ff9ec0", "#c24eea", screenshot()),
    "xlin-store": ("#6fd0ff", "#3b6df0", store()),
    "xlin-media": ("#ff8a7a", "#e5484d", media()),
    "xlin-debug": ("#ffc857", "#ef8a17", debug()),
    "xlin-clock": ("#8a8d99", "#3a3b44", clock()),
    "xlin-power": ("#ff6b5e", "#d62f2f", power("#d62f2f")),
}

if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    for name, (c1, c2, body) in ICONS.items():
        open(os.path.join(OUT, name + ".svg"), "w").write(icon(name, c1, c2, body))
        print("wrote", name)
