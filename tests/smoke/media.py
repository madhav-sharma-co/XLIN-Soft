import types
K = mod.Gdk
win.add([os.environ['SMOKE_FILES'] + ''], True)
assert len(win.playlist) == 2, win.playlist
win.toggle_play(); win.toggle_play()
win.step(1); win.step(-1); win.stop(); win.play(1)
win.jump(10); win.jump(-10)
for rep in range(3): win.cycle_repeat()
win.shuffle = True; win.step(1); win.shuffle = False
win.on_eos(); win.repeat='one'; win.on_eos(); win.repeat='all'; win.index=1; win.on_eos()
win.toggle_mute(); win.toggle_mute()
win.change_speed(1); win.change_speed(-1)
win.toggle_fullscreen(); win.wake_controls(); win.hide_controls(); win.toggle_fullscreen()
win.tick(); win.on_state(); win.on_error('x'); win.on_tags(Fake())
b = Fake()
for f in (win.fill_subs, win.fill_audio, win.fill_eq, win.fill_info, win.fill_url):
    f(b, Fake())
win.list.get_selected_row = lambda: types.SimpleNamespace(idx=0)
win.list.get_first_child = lambda: None
win.remove_selected(); win.clear(); win.show_idle()
for key in (K.KEY_space,K.KEY_Right,K.KEY_Left,K.KEY_Up,K.KEY_Down,K.KEY_f,K.KEY_m,K.KEY_n,K.KEY_p,K.KEY_s,K.KEY_l,K.KEY_bracketleft):
    win.on_key(None, key, 0, 0)
win.on_seek(None, None, 12.0); win.on_volume(win.vol_bar)
win.pick_files; win.pick_folder; win.pick_subtitle
