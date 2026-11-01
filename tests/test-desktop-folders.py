#!/usr/bin/env python3
"""Logic of the desktop's app folders and real-folder moves, with GTK replaced by stand-ins (no display needed)."""
import importlib.machinery
import importlib.util
import os
import sys
import tempfile
import types
from unittest import mock

os.environ["XLIN_DESKTOP_REEXEC"] = "1"
home = tempfile.mkdtemp()
os.environ["HOME"] = home

gi = types.ModuleType("gi")
gi.require_version = lambda *a, **k: None
repo = types.ModuleType("gi.repository")
class Base:                       # stand-in for Gtk.Window / Gtk.Application
    def __init__(self, *a, **k): pass
mocks = {n: mock.MagicMock() for n in ("Gdk", "Gio", "GLib", "Gtk", "Pango", "Gtk4LayerShell")}
mocks["Gtk"].Window = Base
mocks["Gtk"].Application = Base
mocks["GLib"].get_user_special_dir = lambda *_: None      # no desktop folder configured at all
for n, m in mocks.items():
    setattr(repo, n, m)
gi.repository = repo
sys.modules.update({"gi": gi, "gi.repository": repo})
ui = types.ModuleType("xlin_ui"); ui.ui_scale = lambda: 1.0; ui.scaled = lambda n: n
sys.modules["xlin_ui"] = ui

path = os.path.join(os.path.dirname(__file__), "..", "bin", "xlin-desktop")
loader = importlib.machinery.SourceFileLoader("xdesk", path)
spec = importlib.util.spec_from_loader("xdesk", loader)
xd = importlib.util.module_from_spec(spec)
loader.exec_module(xd)

fail = 0
def check(name, cond):
    global fail
    print(("ok: " if cond else "FAIL: ") + name)
    fail |= not cond

# 1. no XDG desktop: ~/Desktop is used and created, so "New folder" shows up
d = xd.desktop_dir()
check("desktop folder falls back to ~/Desktop", d == os.path.join(home, "Desktop") and os.path.isdir(d))

# 2. widget transparency: default, clamped, read from the state file
os.makedirs(xd.STATE, exist_ok=True)
check("default widget opacity is 65", xd.widget_opacity() == 65)
for text, want in (("90", 90), ("5", 15), ("500", 100), ("junk", 65)):
    open(os.path.join(xd.STATE, "widget_opacity"), "w").write(text)
    check(f"widget opacity '{text}' -> {want}", xd.widget_opacity() == want)
open(os.path.join(xd.STATE, "widget_opacity"), "w").write("40")
check("css uses the opacity", "rgba(255,255,255,0.40)" in xd.desktop_css())

# 3. app folders: a window object with just the bookkeeping, the GTK drawing is stubbed
class Fake(xd.DesktopWindow):
    def __init__(self):
        self.cfg = {"icons": [], "folders": [], "files": {}, "icon_size": "medium"}
        self.items = {}
    def add_app_icon(self, item):
        self.items["app:" + item["id"]] = {"key": "app:" + item["id"], "store": item}; return True
    def add_folder_icon(self, f):
        self.items["folder:" + f["id"]] = {"key": "folder:" + f["id"], "store": f}
    def remove_item_widget(self, key): self.items.pop(key, None)
    def refresh_files(self): pass
    def free_cell(self): return (5, 5)

xd.save_config = lambda cfg: None
xd.Gio.DesktopAppInfo.new = lambda aid: object()         # every app "exists"
w = Fake()
for i, aid in enumerate(("a.desktop", "b.desktop", "c.desktop")):
    item = {"id": aid, "x": i, "y": 0}
    w.cfg["icons"].append(item); w.add_app_icon(item)

check("app dropped on app makes a folder", w.merge(w.items["app:a.desktop"], w.items["app:b.desktop"]))
check("one folder with both apps", len(w.cfg["folders"]) == 1 and w.cfg["folders"][0]["apps"] == ["b.desktop", "a.desktop"])
check("the two shortcuts are gone", [i["id"] for i in w.cfg["icons"]] == ["c.desktop"])
f = w.cfg["folders"][0]
check("folder sits where the target was", (f["x"], f["y"]) == (1, 0))
check("app dropped on folder joins it", w.merge(w.items["app:c.desktop"], w.items["folder:" + f["id"]]) and f["apps"][-1] == "c.desktop")
check("no shortcuts left", w.cfg["icons"] == [])
w.take_out = None
w.dissolve_folder(f)
check("removing the folder brings the apps back", sorted(i["id"] for i in w.cfg["icons"]) == ["a.desktop", "b.desktop", "c.desktop"] and w.cfg["folders"] == [])

# 4. a file dropped on a real folder moves into it
os.makedirs(os.path.join(d, "Stuff"))
open(os.path.join(d, "note.txt"), "w").write("hi")
w2 = Fake()
w2.items = {"file:note.txt": {"key": "file:note.txt", "store": {}}, "file:Stuff": {"key": "file:Stuff", "store": {}}}
check("file dropped on a folder moves in", w2.merge(w2.items["file:note.txt"], w2.items["file:Stuff"])
      and os.path.exists(os.path.join(d, "Stuff", "note.txt")) and not os.path.exists(os.path.join(d, "note.txt")))
# a folder dropped on a plain file does nothing
w2.items = {"file:Stuff": {"key": "file:Stuff", "store": {}}, "file:other.txt": {"key": "file:other.txt", "store": {}}}
open(os.path.join(d, "other.txt"), "w").write("x")
check("dropping on a plain file does nothing", not w2.merge(w2.items["file:Stuff"], w2.items["file:other.txt"]))
# add real files and folders to the desktop (as links)
src = os.path.join(home, "Docs"); os.makedirs(src)
w2.add_paths([src])
check("added folder shows on the desktop as a link", os.path.islink(os.path.join(d, "Docs")))
sys.exit(fail)
