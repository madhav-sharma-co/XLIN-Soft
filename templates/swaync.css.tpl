* {
  font-family: "@C_FONT@", "Inter", "Symbols Nerd Font", "Font Awesome 7 Free", "Font Awesome 6 Free", sans-serif;
  font-size: @C_FS_BAR@px;
}

.control-center {
  background: @C_PANEL@;
  border: 1px solid @C_LINE_SOLID@;
  border-radius: 16px;
  padding: 16px;
  color: @C_INK@;
  box-shadow: 0 18px 50px rgba(20, 28, 48, 0.28);
}

.control-center .widget-title {
  margin: 2px 2px 14px 2px;
  font-size: 17px;
  font-weight: 700;
  letter-spacing: 0.2px;
}
.control-center .widget-title > button {
  padding: 5px 14px;
  border-radius: 10px;
  font-size: 12px;
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
  min-height: 46px;
  margin: 4px;
  padding: 0 14px;
  border-radius: 14px;
  background: @C_SOFT@;
  color: @C_INK@;
  border: none;
  box-shadow: none;
  font-size: 12px;
  font-weight: 600;
  transition: background 120ms ease-out, color 120ms ease-out;
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

/* silent mode: a small round button (the bell), not a wide one */
.widget-buttons-grid#sound > flowbox > flowboxchild > button,
#sound > flowbox > flowboxchild > button {
  min-width: 44px; min-height: 44px; padding: 0; border-radius: 50%;
  margin: 4px;
}
/* the volume and brightness sliders: each one on its own soft card, with a round handle */
.widget-volume, .widget-backlight {
  background: @C_SOFT@;
  border-radius: 14px;
  padding: 10px 14px;
  margin: 4px;
  color: @C_INK@;
  font-size: 15px;
}
.widget-volume scale, .widget-backlight scale { padding: 0; margin: 0 0 0 10px; min-height: 0; }
scale trough {
  background: alpha(@C_MUTED@, 0.28);
  border: none;
  border-radius: 4px;
  min-height: 6px;
  min-width: 0;
  padding: 0;
  margin: 0;
}
scale trough highlight { background: @C_ACCENT@; border-radius: 4px; min-height: 6px; }
scale trough slider {
  background: @C_ACCENT@;
  border: 3px solid @C_PANEL@;
  border-radius: 50%;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.25);
  min-width: 12px;
  min-height: 12px;
  margin: -7px;
}

.notification-row { outline: none; }
.notification {
  background: @C_SOFT@;
  border: none;
  border-radius: 14px;
  margin: 6px 4px;
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
