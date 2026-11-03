for k in ('general','connectivity','desktop','apps','personalization','about'):
    win.show_page(k)
for k in ('bars','launcher','wifi','sound','appearance','mouse'):
    win.show_page(k)
win.rebuild('desktop'); win.refresh()
