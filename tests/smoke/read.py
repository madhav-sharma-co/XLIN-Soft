K = mod.Gdk
win.open_file(os.environ['SMOKE_FILES'] + '/none.pdf')
# fake a loaded document
class Page:
    def get_size(self): return (600.0, 800.0)
    def find_text(self, t): return [types.SimpleNamespace(x1=1,y1=2,x2=30,y2=12)]
import types
win.pages = [mod.PageView(win, i, Page()) for i in range(3)]
win.doc = Fake()
win.fit(); win.set_zoom(1.5); win.zoom_by(0.9); win.current_page(); win.goto_page(2); win.goto_text('2'); win.on_scrolled()
win.show_find(); win.find_entry.get_text = lambda: 'a'
win.run_search(); win.find_step(1); win.find_step(-1); win.hide_find()
win.set_night(True); win.set_night(False); win.toggle_fullscreen(); win.wake(); win.toggle_fullscreen()
win.fill_outline(); win.check_width(); win.trim_cache(win.pages[0])
win.on_wheel(Fake(), 0, 1)
for key in (K.KEY_Page_Down,K.KEY_Page_Up,K.KEY_Home,K.KEY_End,K.KEY_w,K.KEY_n,K.KEY_b,K.KEY_f,K.KEY_F3,K.KEY_space):
    win.on_key(None, key, 0, 0)
for key in (K.KEY_o,K.KEY_f,K.KEY_g,K.KEY_plus,K.KEY_minus,K.KEY_0):
    win.on_key(None, key, 0, 4)
