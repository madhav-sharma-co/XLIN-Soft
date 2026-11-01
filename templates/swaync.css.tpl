* {
  font-family: "@C_FONT@", "Inter", "Symbols Nerd Font", "Font Awesome 7 Free", "Font Awesome 6 Free", sans-serif;
  font-size: @C_FS_BAR@px;
}

.control-center {
  background: @C_PANEL@;
  border: 1px solid @C_LINE_SOLID@;
  border-radius: 11px;
  padding: 15px;
  color: @C_INK@;
}

.control-center .widget-title {
  margin: 0 0 12px 0;
  font-size: 14px;
  font-weight: 700;
}
.control-center .widget-title > button {
  padding: 4px 12px;
  border-radius: 8px;
  background: @C_SOFT@;
  color: @C_INK@;
  border: none;
}
.control-center .widget-title > button:hover { background: @C_ACCENT_SOFT@; }

.widget-menubar { background: transparent; margin: 0 0 4px 0; }
.widget-menubar button {
  min-width: 26px; min-height: 26px; padding: 0 8px;
  border-radius: 13px;
  background: transparent; color: @C_MUTED@; border: none; box-shadow: none;
}
.widget-menubar button:hover { background: #e5484d; color: #ffffff; }

.widget-buttons-grid {
  background: transparent;
  margin-bottom: 12px;
}
.widget-buttons-grid > flowbox > flowboxchild > button {
  min-height: 38px;
  margin: 3px;
  padding: 0 10px;
  border-radius: 8px;
  background: @C_SOFT@;
  color: @C_INK@;
  border: none;
  box-shadow: none;
  font-size: 11px;
}
.widget-buttons-grid > flowbox > flowboxchild > button:hover {
  background: alpha(@C_ACCENT@, 0.22);
}
/* a switched-on button is filled with the accent colour, a switched-off one stays soft (like a phone's control centre) */
.widget-buttons-grid > flowbox > flowboxchild > button:checked,
.widget-buttons-grid > flowbox > flowboxchild > button.toggle:checked {
  background: @C_ACCENT@;
  color: @C_ON_ACCENT@;
}
.widget-buttons-grid > flowbox > flowboxchild > button:checked:hover,
.widget-buttons-grid > flowbox > flowboxchild > button.toggle:checked:hover {
  background: @C_ACCENT@;
  color: @C_ON_ACCENT@;
  opacity: 0.9;
}

/* thin, flat sliders: a 3px line with a tiny dot, no big pill */
.widget-volume, .widget-backlight {
  background: transparent;
  padding: 2px 4px;
  margin: 0;
  color: @C_MUTED@;
}
.widget-volume scale, .widget-backlight scale { padding: 0; margin: 0; min-height: 0; }
scale trough {
  background: @C_SOFT@;
  border: none;
  border-radius: 3px;
  min-height: 3px;
  min-width: 0;
  padding: 0;
  margin: 0;
}
scale trough highlight { background: @C_ACCENT@; border-radius: 3px; min-height: 3px; }
scale trough slider {
  background: @C_ACCENT@;
  border: none;
  border-radius: 50%;
  box-shadow: none;
  min-width: 10px;
  min-height: 10px;
  margin: -4px;
}

.notification-row { outline: none; }
.notification {
  background: @C_PANEL@;
  border: 1px solid @C_LINE_SOLID@;
  border-radius: 10px;
  margin: 6px 12px;
  padding: 0;
  color: @C_INK@;
}
.notification-content { padding: 10px; background: transparent; }
.summary { font-weight: 700; color: @C_INK@; }
.body, .time { color: @C_MUTED@; }
.floating-notifications.background .notification { box-shadow: 0 12px 35px rgba(30, 43, 67, 0.2); }

/* the scroll bar on the right of the notification list: slim, same look as in the Xlin-soft apps */
scrollbar { background: transparent; }
scrollbar trough { background-color: @C_SOFT@; border-radius: 6px; min-width: 8px; }
scrollbar slider { background-color: @C_MUTED@; border-radius: 6px; min-width: 6px; min-height: 36px; margin: 1px; border: none; }
scrollbar slider:hover { background-color: @C_ACCENT@; }
