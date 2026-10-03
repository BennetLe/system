# Siril's Python scripts run in a pip venv (~/.local/share/siril/venv); the
# manylinux wheels there (numpy, opencv, PyQt6, ...) need these libs at runtime.
final: prev: let
  runtimeLibs = with prev; [
    stdenv.cc.cc.lib
    zlib
    zstd
    glib
    libglvnd
    dbus
    fontconfig
    freetype
    krb5
    pcsclite
    libpulseaudio
    libdrm
    # X11 / xcb (Qt xcb platform plugin)
    libx11
    libxext
    libxrandr
    libxcb
    libxcb-cursor
    libxcb-wm
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-util
    libxkbcommon
    # Wayland (Qt wayland platform plugin)
    wayland
  ];
in {
  siril = prev.symlinkJoin {
    name = "siril-${prev.siril.version}";
    paths = [prev.siril];
    nativeBuildInputs = [prev.makeWrapper];
    postBuild = ''
      for bin in $out/bin/siril $out/bin/siril-cli; do
        if [ -e "$bin" ]; then
          wrapProgram "$bin" --suffix LD_LIBRARY_PATH : ${prev.lib.makeLibraryPath runtimeLibs}
        fi
      done
    '';
    inherit (prev.siril) meta;
  };
}
