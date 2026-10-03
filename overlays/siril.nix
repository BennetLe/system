# Siril's Python scripts run in a pip venv (~/.local/share/siril/venv); the
# manylinux wheels there (numpy, opencv, ...) need these libs at runtime.
final: prev: {
  siril = prev.symlinkJoin {
    name = "siril-${prev.siril.version}";
    paths = [prev.siril];
    nativeBuildInputs = [prev.makeWrapper];
    postBuild = ''
      for bin in $out/bin/siril $out/bin/siril-cli; do
        if [ -e "$bin" ]; then wrapProgram "$bin" \
          --suffix LD_LIBRARY_PATH : ${prev.lib.makeLibraryPath [
        prev.stdenv.cc.cc.lib
        prev.zlib
        prev.libglvnd
        prev.glib
      ]}; fi
      done
    '';
    inherit (prev.siril) meta;
  };
}
