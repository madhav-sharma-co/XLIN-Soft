import types
win.book.get_current_page = lambda: len(win.docs) - 1
K = mod.Gdk
win.new_doc()
win.open_paths([os.environ['SMOKE_FILES'] + '/t.txt', os.environ['SMOKE_FILES'] + '/nope.txt'])
d = win.docs[-1]
assert d.get_text() is not None
win.docs[0].path = None
d.buffer.get_selection_bounds = lambda: (Fake(), Fake())
win.show_find(True); win.find_entry.get_text = lambda: 'o'
win.find_next(False); win.find_next(True); win.find_next(False, keep=True)
win.replace_entry.get_text = lambda: 'X'
win.replace_one(); win.replace_all(); win.hide_find()
win.undo(); win.redo(); win.set_wrap(True); win.set_zoom(14); win.goto_line()
win.update_status(); win.on_switch(); win.apply_scheme()
win.save_current(False); win.save_current(True)
d.save(os.environ['SMOKE_FILES'] + '/t2.txt')
win.close_doc(d, True); win.on_close_request()
for key in (K.KEY_F11, K.KEY_Escape):
    win.on_key(None, key, 0, 0)
for key in (K.KEY_n,K.KEY_o,K.KEY_s,K.KEY_w,K.KEY_f,K.KEY_h,K.KEY_g,K.KEY_z,K.KEY_y,K.KEY_plus,K.KEY_minus,K.KEY_0):
    win.on_key(None, key, 0, 4)
