"""Shared pieces for the Xlin-soft apps: the three window buttons (hide, fullscreen, close) and the title bar.

Panels (control panel, launcher) are not windows: they only get a close button.
"""
import json
import os
import subprocess

from gi.repository import Gtk


_MODE = None


def hypr_is_lua():
    """True when Hyprland reads a Lua config (hyprland.lua, always the case from Hyprland 0.57)."""
    global _MODE
    if _MODE is None:
        try:
            out = subprocess.run(["xlin", "hypr-mode"], capture_output=True, text=True, timeout=3).stdout.strip()
        except Exception:
            out = ""
        _MODE = out or ("lua" if os.path.exists(os.path.expanduser("~/.config/hypr/hyprland.lua")) else "conf")
    return _MODE == "lua"


def _hypr(*args):
    try:
        subprocess.Popen(["hyprctl", *args], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except OSError:
        pass


def hypr_lua(code):
    """Run Lua inside Hyprland (hyprctl eval)."""
    _hypr("eval", code)


def _address(win):
    """Hyprland's address for this very window (not whichever one happens to be focused)."""
    try:
        out = subprocess.run(["hyprctl", "clients", "-j"], capture_output=True, text=True, timeout=2).stdout
        mine = [c for c in json.loads(out) if c.get("pid") == os.getpid()]
    except Exception:
        return None
    if len(mine) > 1:
        title = win.get_title() if win is not None else None
        same = [c for c in mine if c.get("title") == title]
        mine = same or mine
    return mine[0]["address"] if mine else None


def _in_hidden_cover(addr):
    """True when the window sits in the hidden-windows space that is shown on top of the desktop."""
    try:
        out = subprocess.run(["hyprctl", "clients", "-j"], capture_output=True, text=True, timeout=2).stdout
        return any(c.get("address") == addr and c.get("workspace", {}).get("name") == "special:xlin-hidden"
                   for c in json.loads(out))
    except Exception:
        return False


def hide_window(win=None):
    """Send this window out of sight (the Run Bar, Alt+Tab, Super+H or `xlin unhide` bring it back)."""
    addr = _address(win)
    if addr and _in_hidden_cover(addr):
        # the window was brought back by something that left it in the hidden space: make it a normal window first
        subprocess.run(["xlin", "restore-shown"], capture_output=True, timeout=5)
    if addr:
        if hypr_is_lua():
            hypr_lua('hl.dispatch(hl.dsp.window.move({ workspace = "special:xlin-hidden", follow = false, '
                     f'window = "address:{addr}" }}))')
        else:
            _hypr("dispatch", "movetoworkspacesilent", f"special:xlin-hidden,address:{addr}")


def toggle_fullscreen(win=None):
    """Real fullscreen, exactly like Super+F; press again to leave it."""
    addr = _address(win)
    if addr:
        if hypr_is_lua():
            hypr_lua(f'hl.dispatch(hl.dsp.focus({{ window = "address:{addr}" }})); '
                     'hl.dispatch(hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))')
        else:
            _hypr("--batch", f"dispatch focuswindow address:{addr} ; dispatch fullscreen 0")


def toggle_maximize(win=None):
    """Fill the screen without hiding the bars (like the zoom button of other desktops); again to go back."""
    addr = _address(win)
    if addr:
        if hypr_is_lua():
            hypr_lua(f'hl.dispatch(hl.dsp.focus({{ window = "address:{addr}" }})); '
                     'hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))')
        else:
            _hypr("--batch", f"dispatch focuswindow address:{addr} ; dispatch fullscreen 1")


def _button(glyph, tip, css, fn):
    b = Gtk.Button(label=glyph)
    b.add_css_class("win-btn")
    b.add_css_class(css)
    b.set_tooltip_text(tip)
    b.set_focusable(False)
    b.connect("clicked", lambda _b: fn())
    return b


def close_button(win):
    return _button("✕", "Close", "win-close", win.close)


def controls(win, hide=True, full=True):
    """The row of buttons: hide, fullscreen, close (in that order)."""
    box = Gtk.Box(spacing=4)
    box.add_css_class("win-controls")
    if hide:
        box.append(_button("–", "Hide", "win-hide", lambda: hide_window(win)))
    if full:
        box.append(_button("▢", "Fullscreen", "win-full", lambda: toggle_fullscreen(win)))
    box.append(close_button(win))
    return box


def titlebar(win, title, hide=True, full=True):
    """Replace the system title bar with Xlin-soft's: title on the left, buttons on the right, drag to move."""
    handle = Gtk.WindowHandle()
    strip = Gtk.Box(spacing=8)
    strip.add_css_class("xlin-titlebar")
    label = Gtk.Label(label=title, xalign=0, hexpand=True)
    label.add_css_class("tool-title")
    strip.append(label)
    strip.append(controls(win, hide, full))
    if full:        # double-click the title bar: fill the screen / go back
        dbl = Gtk.GestureClick(button=1)
        dbl.connect("pressed", lambda g, n, _x, _y: toggle_maximize(win) if n == 2 else None)
        strip.add_controller(dbl)
    handle.set_child(strip)
    win.set_titlebar(handle)
    return label


# ---- app list helpers shared by the Launcher (Start menu)
def read_ids(path):
    try:
        with open(path) as f:
            return [ln.strip() for ln in f if ln.strip()]
    except OSError:
        return []


def run(cmd):
    try:
        subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)
    except OSError:
        pass


def load_apps():
    """[(id, name, gicon)] of every app that should show in a menu, A-Z."""
    from gi.repository import Gio
    apps, seen = [], set()
    for a in Gio.AppInfo.get_all():
        if not a.should_show() or not a.get_id():
            continue
        aid = a.get_id()
        aid = aid[:-8] if aid.endswith(".desktop") else aid
        if aid not in seen:
            seen.add(aid)
            apps.append((aid, a.get_display_name(), a.get_icon()))
    apps.sort(key=lambda x: x[1].lower())
    return apps


def fuzzy(query, text):
    """Score of query as a fuzzy match inside text; None if no match. Lower is better."""
    q, t = query.lower(), text.lower()
    if t.startswith(q):
        return 0
    if q in t:
        return 1 + t.index(q) / 100
    pos, gaps = -1, 0
    for ch in q:
        nxt = t.find(ch, pos + 1)
        if nxt < 0:
            return None
        gaps += nxt - pos - 1
        pos = nxt
    return 2 + gaps / 100


# ---- the theme: tools.css is rewritten by `xlin theme` / `xlin font`; apps restyle themselves at once
CSS_PATH = os.path.expanduser("~/.config/xlin/tools.css")
_LIVE = {}


def smooth_wheel(sw):
    """Mouse-wheel scrolling that glides to its target instead of jumping (touchpads already scroll smoothly).
    Attached to every ScrolledWindow made after live_css() ran, so it works everywhere in Xlin-soft."""
    from gi.repository import Gtk as _Gtk
    st = {"target": None, "tick": 0, "last": 0}

    def on_scroll(_c, _dx, dy):
        adj = sw.get_vadjustment()
        room = adj.get_upper() - adj.get_page_size() - adj.get_lower()
        if room <= 0 or dy == 0:
            return False                       # nothing to scroll here: let a parent scroll area have it
        lo, hi = adj.get_lower(), adj.get_upper() - adj.get_page_size()
        base = st["target"] if st["tick"] and st["target"] is not None else adj.get_value()
        if (dy > 0 and adj.get_value() >= hi - 0.5 and not st["tick"]) or (dy < 0 and adj.get_value() <= lo + 0.5 and not st["tick"]):
            return False                       # already at the end: pass it on
        step = max(40.0, adj.get_page_size() ** (2.0 / 3.0)) * 1.4
        st["target"] = max(lo, min(hi, base + dy * step))
        if not st["tick"]:
            st["last"] = 0
            st["tick"] = sw.add_tick_callback(on_tick)
        return True

    def on_tick(widget, clock):
        adj = widget.get_vadjustment()
        now = clock.get_frame_time()
        dt = (now - st["last"]) / 1e6 if st["last"] else 0.016
        st["last"] = now
        diff = st["target"] - adj.get_value()
        if abs(diff) < 0.6:
            adj.set_value(st["target"])
            st["tick"] = 0
            return False                       # GLib.SOURCE_REMOVE
        k = 1.0 - pow(2.718281828, -dt / 0.07)  # about 70 ms to close most of the gap, whatever the frame rate
        adj.set_value(adj.get_value() + diff * k)
        return True

    ctl = _Gtk.EventControllerScroll.new(_Gtk.EventControllerScrollFlags.VERTICAL | _Gtk.EventControllerScrollFlags.DISCRETE)
    ctl.set_propagation_phase(_Gtk.PropagationPhase.CAPTURE)
    ctl.connect("scroll", on_scroll)
    sw.add_controller(ctl)


def _patch_scrolled_windows():
    from gi.repository import Gtk as _Gtk
    if getattr(_Gtk.ScrolledWindow, "_xlin_smooth", False):
        return
    orig = _Gtk.ScrolledWindow.__init__

    def init(self, *a, **k):
        orig(self, *a, **k)
        try:
            smooth_wheel(self)
        except Exception:
            pass
    _Gtk.ScrolledWindow.__init__ = init
    _Gtk.ScrolledWindow._xlin_smooth = True


def live_css():
    """Load Xlin-soft's stylesheet and keep it current. Warm (hidden) apps and open menus follow a theme or font
    change immediately, so dark / light and the font size apply everywhere without restarting anything."""
    if _LIVE:
        return
    from gi.repository import Gdk, Gio, GLib
    try:    # every scroll area glides with the mouse wheel
        _patch_scrolled_windows()
    except Exception:
        pass
    try:    # a scroll bar is always there on the right (not only while scrolling), so long pages can be navigated
        Gtk.Settings.get_default().set_property("gtk-overlay-scrolling", False)
    except Exception:
        pass
    prov = Gtk.CssProvider()
    state = {"pending": False}

    def load():
        state["pending"] = False
        try:
            with open(CSS_PATH, "rb") as f:
                prov.load_from_data(f.read())
        except Exception:
            pass
        return False

    def changed(_m, _f, _o, _ev):
        if not state["pending"]:          # one reload per burst of write events
            state["pending"] = True
            GLib.timeout_add(150, load)
    load()
    display = Gdk.Display.get_default()
    if display is None:
        return
    Gtk.StyleContext.add_provider_for_display(display, prov, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION + 1)
    try:
        mon = Gio.File.new_for_path(CSS_PATH).monitor_file(Gio.FileMonitorFlags.NONE, None)
        mon.connect("changed", changed)
        _LIVE.update(provider=prov, monitor=mon)
    except Exception:
        _LIVE.update(provider=prov)


def ui_scale():
    """1.0 normally; the Settings -> Font size choice scales window sizes the same way as the text."""
    try:
        with open(os.path.join(os.path.expanduser("~/.config/xlin/state"), "ui_size")) as f:
            return {"small": 0.92, "large": 1.12, "huge": 1.25}.get(f.read().strip(), 1.0)
    except OSError:
        return 1.0


def scaled(n):
    return int(n * ui_scale()) if n > 0 else n


# ---- "keep apps ready": a closed window is only hidden, so it opens instantly next time
STATE_DIR = os.path.expanduser("~/.config/xlin/state")


def warm_on():
    return not os.path.exists(os.path.join(STATE_DIR, "warm_off"))


def keep_warm(app, win):
    """Closing the window hides it (the app keeps running) while 'Keep apps ready' is on."""
    if warm_on():
        app.hold()

    def closing(_w):
        if warm_on():
            win.set_visible(False)
            return True
        return False
    win.connect("close-request", closing)


def user_name():
    import getpass
    try:
        import pwd
        full = pwd.getpwnam(getpass.getuser()).pw_gecos.split(",")[0].strip()
        return full or getpass.getuser()
    except Exception:
        return getpass.getuser()


def footer(close):
    """The bottom row of the Launcher: your name, then Settings and Power."""
    bar = Gtk.Box(spacing=6)
    bar.add_css_class("start-footer")
    name = Gtk.Label(label=user_name(), xalign=0, hexpand=True)
    name.add_css_class("start-user")
    bar.append(name)
    for glyph, tip, cmd in (("⚙", "Settings", ["xlin", "settings"]), ("⏻", "Power", ["xlin", "session"])):
        b = Gtk.Button(label=glyph)
        b.add_css_class("win-btn")
        b.set_tooltip_text(tip)
        b.set_focusable(False)
        b.connect("clicked", lambda _b, c=cmd: (run(c), close()))
        bar.append(b)
    return bar


# ---- pins: apps pinned in the Launcher (Start menu) and apps pinned on the Run Bar
LPINS = os.path.join(STATE_DIR, "launcher_pins")
RPINS = os.path.expanduser("~/.cache/nwg-dock-pinned")


def launcher_pins():
    """None if nothing was ever pinned in the Launcher, else the list of app ids."""
    return read_ids(LPINS) if os.path.exists(LPINS) else None


def set_launcher_pin(aid, on):
    ids = [i for i in (launcher_pins() or []) if i != aid]
    if on:
        ids.append(aid)
    os.makedirs(STATE_DIR, exist_ok=True)
    with open(LPINS, "w") as f:
        f.write("".join(i + "\n" for i in ids))


def app_menu(parent, x, y, aid, refresh=None, hold=None):
    """Right-click menu for an app: Open, pin / unpin on the Run Bar, pin / unpin in the Launcher."""
    from gi.repository import Gdk, GLib
    on_bar = aid in read_ids(RPINS)
    in_start = aid in (launcher_pins() or [])
    pop = Gtk.Popover()
    pop.add_css_class("files-menu")
    pop.set_parent(parent)
    pop.set_has_arrow(False)
    rect = Gdk.Rectangle()
    rect.x, rect.y, rect.width, rect.height = int(x), int(y), 1, 1
    pop.set_pointing_to(rect)
    pending = []
    box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
    box.set_size_request(scaled(210), -1)

    def pin_launcher():
        set_launcher_pin(aid, not in_start)
        if refresh:
            refresh()
    entries = [("Open", lambda: run(["xlin", "launch-app", aid])),
               ("Unpin from the Run Bar" if on_bar else "Pin to the Run Bar",
                lambda: run(["xlin", "unpin" if on_bar else "pin", aid])),
               ("Unpin from the Launcher" if in_start else "Pin to the Launcher", pin_launcher)]
    for label, fn in entries:
        b = Gtk.Button(label=label, halign=Gtk.Align.FILL)
        b.get_child().set_xalign(0)
        b.add_css_class("files-menu-item")
        b.connect("clicked", lambda _b, f=fn: (pending.append(f), pop.popdown()))
        box.append(b)
    pop.set_child(box)

    def closed(p):
        def finish():
            p.unparent()
            for f in pending:          # the chosen action runs once the menu is gone (it may rebuild this very list)
                f()
            return False
        if hold:
            GLib.timeout_add(250, lambda: (hold(False), False)[1])
        GLib.idle_add(finish)
    pop.connect("closed", closed)
    if hold:
        hold(True)
    pop.popup()


def default_size(w=920, h=640):
    """(width, height) for a normal app window: the size of Settings, never more than 85% of the screen."""
    w, h = scaled(w), scaled(h)
    try:
        from gi.repository import Gdk
        geo = Gdk.Display.get_default().get_monitors().get_item(0).get_geometry()
        w, h = min(w, int(geo.width * 0.85)), min(h, int(geo.height * 0.85))
    except Exception:       # noqa: BLE001
        pass
    return w, h
