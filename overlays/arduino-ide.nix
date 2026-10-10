final: prev: {
  # Arduino IDE won't launch under Wayland; force it onto XWayland.
  arduino-ide = prev.symlinkJoin {
    name = "arduino-ide";
    paths = [
      (prev.writeShellScriptBin "arduino-ide" ''
        exec ${prev.arduino-ide}/bin/arduino-ide --ozone-platform=x11 "$@"
      '')
      prev.arduino-ide
    ];
  };
}
