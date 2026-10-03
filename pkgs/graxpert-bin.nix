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
  version = "3.0.2";

  src = fetchurl {
    url = "https://github.com/Steffenhir/GraXpert/releases/download/${finalAttrs.version}/graxpert-linux-amd64.zip";
    hash = "sha256-CnNkwzBLoZ8SIx1TPICylAVNZVjVTs2BZo5N7EkJJYg=";
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
    "libcublas.so.12"
    "libcublasLt.so.12"
    "libcudart.so.12"
    "libcudnn.so.8"
    "libcufft.so.11"
    "libcurand.so.10"
    "libnvinfer.so.8"
    "libnvinfer_plugin.so.8"
    "libnvonnxparser.so.8"
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
