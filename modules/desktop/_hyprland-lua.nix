# Helpers for writing Hyprland's Lua config through Home Manager.
lib: rec {
  bind = keys: dispatcher: {
    _args = [
      keys
      (lib.generators.mkLuaInline dispatcher)
    ];
  };
  bindWith = opts: keys: dispatcher: {
    _args = [
      keys
      (lib.generators.mkLuaInline dispatcher)
      opts
    ];
  };
  exec = cmd: "hl.dsp.exec_cmd(${builtins.toJSON cmd})";
  # Launch apps in their own systemd scopes under UWSM.
  app = cmd: exec "uwsm app -- ${cmd}";
}
