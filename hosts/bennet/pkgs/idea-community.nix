{pkgs, ...}: let
  libs = with pkgs; [
    libpulseaudio
    libGL
    glfw
    openal
    stdenv.cc.cc.lib
    wayland
  ];
in
  pkgs.symlinkJoin {
    name = "idea-community";
    paths = [pkgs.jetbrains.idea-community];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/idea-community \
      --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath libs}"
    '';
  }
