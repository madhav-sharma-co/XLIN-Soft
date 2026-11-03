import types
win.open_paths([os.environ['SMOKE_FILES'] + '/x.png'])
win.pixbuf = types.SimpleNamespace(get_width=lambda: 100, get_height=lambda: 50, rotate_simple=lambda h: win.pixbuf, flip=lambda h: win.pixbuf)
win.scroll.get_width = lambda: 800
win.scroll.get_height = lambda: 600
K = mod.Gdk
win.open_paths([os.environ['SMOKE_FILES'] + ''])
win.step(1); win.step(-1); win.fit(); win.zoom_by(1.25); win.set_zoom(2.0); win.current_zoom()
win.rotate(1); win.flip(); win.copy(); win.set_wallpaper(); win.fill_info()
win.toggle_slide(); win.toggle_slide(); win.toggle_fullscreen(); win.wake(); win.toggle_fullscreen()
win.on_wheel(Fake(), 0, 1)
for key in (K.KEY_Right,K.KEY_Left,K.KEY_Home,K.KEY_End,K.KEY_plus,K.KEY_minus,K.KEY_0,K.KEY_1,K.KEY_r,K.KEY_f,K.KEY_space,K.KEY_i):
    win.on_key(None, key, 0, 0)
win.on_key(None, K.KEY_c, 0, 4)
win.trash()
