{
  lib,
  stdenv,
  fetchurl,
  unzip,
  autoPatchelfHook,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  libx11,
  libxext,
  libxrender,
  libxcb,
  libice,
  libsm,
  libglvnd,
  glib,
  expat,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "graxpert-bin";
  version = "3.1.0rc2";

  src = fetchurl {
    url = "https://github.com/Steffenhir/GraXpert/releases/download/${finalAttrs.version}/graxpert-linux-amd64.zip";
    hash = "sha256-9lG+Rz/dZSKy6OR9Os/K3tvzzyvpBVKq6TMzlvw1XPk=";
  };

  nativeBuildInputs = [unzip autoPatchelfHook makeWrapper copyDesktopItems];

  buildInputs = [
    stdenv.cc.cc.lib
    libx11
    libxext
    libxrender
    libxcb
    libice
    libsm
    libglvnd
    glib
    expat
    zlib
  ];

  # bundled onnxruntime CUDA/TensorRT providers; CPU inference works without them
  autoPatchelfIgnoreMissingDeps = [
    "libcu*" # CUDA, cuBLAS, cuDNN, cuFFT, cuRAND
    "libnv*" # TensorRT, NVRTC
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "graxpert";
      desktopName = "GraXpert";
      genericName = "Astrophotography Image Processing";
      comment = finalAttrs.meta.description;
      exec = "graxpert";
      icon = "graxpert";
      categories = ["Graphics" "Science" "Astronomy"];
    })
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/opt $out/bin
    cp -r . $out/opt/graxpert
    makeWrapper $out/opt/graxpert/GraXpert $out/bin/graxpert
    install -Dm644 lib/img/Icon.png $out/share/pixmaps/graxpert.png
    runHook postInstall
  '';

  meta = {
    description = "Gradient removal and AI denoising for astrophotos";
    homepage = "https://www.graxpert.com";
    license = lib.licenses.gpl3Only;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    platforms = ["x86_64-linux"];
    mainProgram = "graxpert";
  };
})
