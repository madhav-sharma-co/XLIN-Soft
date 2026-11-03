for i in range(len(win.builders)): win.go(1)
for i in range(len(win.builders)): win.go(-1)
win.set_mode('dark'); win.set_accent('blue'); win.set_idle(True); win.set_autohide(True)
win.on_key(None, mod.Gdk.KEY_Escape, 0, 0)
