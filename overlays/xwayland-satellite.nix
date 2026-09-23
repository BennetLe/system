final: prev: {
  # 0.8.2 makes Steam's dropdown/context menus close instantly under niri.
  xwayland-satellite = prev.xwayland-satellite.overrideAttrs (old: rec {
    version = "0.8.1";
    src = prev.fetchFromGitHub {
      owner = "Supreeeme";
      repo = "xwayland-satellite";
      tag = "v${version}";
      hash = "sha256-BUE41HjLIGPjq3U8VXPjf8asH8GaMI7FYdgrIHKFMXA=";
    };
    cargoDeps = prev.rustPlatform.fetchCargoVendor {
      inherit src;
      hash = "sha256-16L6gsvze+m7XCJlOA1lsPNELE3D364ef2FTdkh0rVY=";
    };
  });
}
