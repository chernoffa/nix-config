{
  lib,
  python3,
  glib,
}:

# The interpreter Pond's helper scripts run under, as `python3` on the
# shell's PATH.
python3.buildEnv.override {
  extraLibs = [
    python3.pkgs.pygobject3
    python3.pkgs.pyqt6
  ];
  # GLib and Gio's typelibs ship with glib, outside gobject-introspection's
  # default search path.
  makeWrapperArgs = [
    "--prefix"
    "GI_TYPELIB_PATH"
    ":"
    "${lib.getLib glib}/lib/girepository-1.0"
  ];
}
