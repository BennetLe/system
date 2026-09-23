{
  inputs,
  pkgs,
  lib,
  ...
}: {
  wayland.windowManager.niri = {
    settings = {
      environment = {
        XDG_SESSION_TYPE = "wayland";
        # XDG_CURRENT_DESKTOP is left unset here - niri-session sets it itself.
        MOZ_ENABLE_WAYLAND = "1";
        ANKI_WAYLAND = "1";
        QT_AUTO_SCREEN_SCALE_FACTOR = "1";
        # Qt's fallback-platform list is `;`-separated, not `,` - the
        # Hyprland env list has "QT_QPA_PLATFORM=wayland,xcb" (note the `=`),
        # which under Hyprland's own `env` directive silently misparses into
        # a no-op instead of actually setting this var. Not fixing that file
        # (protected), but using the correct separator here since niri's
        # `environment` block sets it for real.
        QT_QPA_PLATFORM = "wayland;xcb";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        SDL_VIDEODRIVER = "wayland";
        CLUTTER_BACKEND = "wayland";
      };
    };
  };
}
