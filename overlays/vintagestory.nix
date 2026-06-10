final: prev: {
  vintagestory = prev.vintagestory.overrideAttrs (oldAttrs: rec {
    version = "1.21.6";
    src = prev.fetchurl {
      url = "https://cdn.vintagestory.at/gamefiles/stable/vs_client_linux-x64_${version}.tar.gz";
      hash = "sha256-LkiL/8W9MKpmJxtK+s5JvqhOza0BLap1SsaDvbLYR0c=";
    };
    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/vintagestory $out/bin $out/share/pixmaps $out/share/fonts/truetype
      cp -r * $out/share/vintagestory
      cp $out/share/vintagestory/assets/gameicon.xpm $out/share/pixmaps/vintagestory.xpm
      cp $out/share/vintagestory/assets/game/fonts/*.ttf $out/share/fonts/truetype

      runHook postInstall
    '';

    preFixup = let
      runtimeLibs = prev.lib.makeLibraryPath (
        [
          prev.gtk2
          prev.sqlite
          prev.openal
          prev.cairo
          prev.libGLU
          prev.SDL2
          prev.freealut
          prev.libglvnd
          prev.pipewire
          prev.libpulseaudio
        ]
        ++ (with prev.xorg; [
          libX11
          libXi
          libXcursor
        ])
      );
    in ''
      makeWrapper ${final.dotnet-runtime_8}/bin/dotnet $out/bin/vintagestory \
        --prefix LD_LIBRARY_PATH : "${runtimeLibs}" \
        --set-default mesa_glthread true \
        --add-flags $out/share/vintagestory/Vintagestory.dll
      makeWrapper ${final.dotnet-runtime_8}/bin/dotnet $out/bin/vintagestory-server \
        --prefix LD_LIBRARY_PATH : "${runtimeLibs}" \
        --set-default mesa_glthread true \
        --add-flags $out/share/vintagestory/VintagestoryServer.dll
      find "$out/share/vintagestory/assets/" -not -path "*/fonts/*" -regex ".*/.*[A-Z].*" | while read -r file; do
        local filename="$(basename -- "$file")"
        ln -sf "$filename" "''${file%/*}"/"''${filename,,}"
      done
    '';
  });
}
