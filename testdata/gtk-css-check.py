# retrocrt — load a GTK 3 CSS file (with its @imports) through GtkCssProvider
# via ctypes and print parse errors; exit 1 on any. Used by verify.sh for Waybar.
# Usage: python3 -I gtk-css-check.py style.css
import ctypes, sys
gtk = ctypes.CDLL("libgtk-3.so.0")
gobject = ctypes.CDLL("libgobject-2.0.so.0")
class GError(ctypes.Structure):
    _fields_ = [("domain", ctypes.c_uint32), ("code", ctypes.c_int), ("message", ctypes.c_char_p)]
gtk.gtk_css_provider_new.restype = ctypes.c_void_p
gtk.gtk_css_provider_load_from_path.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.POINTER(ctypes.POINTER(GError))]
gtk.gtk_css_provider_load_from_path.restype = ctypes.c_int
errors = []
CB = ctypes.CFUNCTYPE(None, ctypes.c_void_p, ctypes.c_void_p, ctypes.POINTER(GError), ctypes.c_void_p)
gtk.gtk_css_section_get_start_line.argtypes = [ctypes.c_void_p]
gtk.gtk_css_section_get_start_line.restype = ctypes.c_uint
gtk.gtk_css_section_get_file.argtypes = [ctypes.c_void_p]
gtk.gtk_css_section_get_file.restype = ctypes.c_void_p
gio = ctypes.CDLL("libgio-2.0.so.0")
gio.g_file_get_basename.argtypes = [ctypes.c_void_p]
gio.g_file_get_basename.restype = ctypes.c_char_p
@CB
def on_error(provider, section, err, data):
    f = gtk.gtk_css_section_get_file(section)
    name = gio.g_file_get_basename(f).decode() if f else "?"
    errors.append(f"{name}:{gtk.gtk_css_section_get_start_line(section)+1}: {err.contents.message.decode()}")
gobject.g_signal_connect_data.argtypes = [ctypes.c_void_p, ctypes.c_char_p, CB, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_int]
p = gtk.gtk_css_provider_new()
gobject.g_signal_connect_data(p, b"parsing-error", on_error, None, None, 0)
e = ctypes.POINTER(GError)()
ok = gtk.gtk_css_provider_load_from_path(p, sys.argv[1].encode(), ctypes.byref(e))
for m in errors: print("ERROR", m)
print("loaded" if ok and not errors else "FAILED")
sys.exit(0 if ok and not errors else 1)
