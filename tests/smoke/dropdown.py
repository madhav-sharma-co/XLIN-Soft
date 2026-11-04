# Wi-Fi, Bluetooth and Volume menus: the shared helpers exist (they once ended up in the wrong class, so the menus
# did not open at all) and the common actions run.
name = type(win).__name__
for n in ("refresh_once", "spawn_read", "refresh", "setup_dropdown", "on_active", "close_if_inactive"):
    assert hasattr(type(win), n), f"{name} has no {n}"
assert win.refresh_once() is False, "refresh_once must return False"
import time
time.sleep(0.3)
if name == "WifiWindow":
    nets = [{"ssid": "Home", "use": True, "sig": 80, "sec": True}, {"ssid": "Cafe", "use": False, "sig": 30, "sec": False},
            {"ssid": "Locked", "use": False, "sig": 55, "sec": True}]
    win.show("enabled", nets, {"Home"}, "wlan0")
    win.show("disabled", [], set(), "")
    for n in nets:
        win.pick(n, {"Home"})
    win.on_switch(None, True)
elif name == "BluetoothWindow":
    win.show(True, [{"mac": "AA:BB:CC:DD:EE:FF", "name": "Buds", "on": True}], True)
    win.show(False, [], True)
    win.show(True, [], False)
    win.scan_done([{"mac": "11:22:33:44:55:66", "name": "Speaker"}])
    win.pair({"mac": "11:22:33:44:55:66", "name": "Speaker"})
    win.on_switch(None, True)
elif name == "VolumeWindow":
    win.show((40, False), [("48", "Speakers", True), ("52", "HDMI", False)])
    win.show((0, True), [])
    win.show(None, [])
    win.on_volume(win.scale)
    win.on_mute(None, True)
