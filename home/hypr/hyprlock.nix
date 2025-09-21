{
  inputs,
  pkgs,
  lib,
  ...
}: {
  programs.hyplock = {
    enable = true;
    settings = {
      general = {
        grace = 1;
      };

      background = {
        # path = "~/Wallpapers/Gruvbox/ign-waifu.png";
        path = "~/Wallpapers/wallpaper.png";
        blur_size = 4;
        blur_passes = 1;
        noise = 0.0117;
        contrast = 1.3;
        brightness = 0.5;
        vibrancy = 0.21;
        vibrancy_darkness = 0.5;
      };

      input-field = {
        size = "250, 50";
        outline_thickness = 0;
        dots_size = 0.2;
        dots_spacing = 0.15;
        dots_center = true;
        fade_on_empty = true;
        placeholder_text = "<i>Password...</i>";
        hide_input = false;
        position = "0, 100";
        halign = "center";
        valign = "bottom";
      };

      label = [
        # Date
        {
          monitor = "";
          text = ''cmd[update:18000000] echo "<b> "$(date +'%A, %-d %B %Y')" </b>"'';
          color = "rgba(184, 212, 224, 0.6)";
          font_size = 28;
          font_family = "JetBrains Mono Nerd Font Mono ExtraBold";
          position = "0, -420";
          halign = "center";
          valign = "top";
        }
        # Time
        {
          monitor = "";
          text = ''cmd[update:1000] echo -e "$(date +"%H":"%M")"'';
          color = "rgba(184, 212, 224, 0.6)";
          font_size = 130;
          font_family = "JetBrains Mono Nerd Font Mono ExtraBold";
          position = "0, -220";
          halign = "center";
          valign = "top";
        }
        # User
        {
          monitor = "";
          text = ''$USER'';
          color = "rgb(126, 247, 138)";
          font_size = 16;
          font_family = "Inter Display Medium";
          position = "0, 70";
          halign = "center";
          valign = "bottom";
        }
        # Uptime
        {
          monitor = "";
          text = ''cmd[update:60000] echo "<b> "$(uptime -p || $Scripts/UptimeNixOS.sh)" </b>"'';
          color = "rgba(184, 212, 224, 0.4)";
          font_size = 12;
          font_family = "JetBrains Mono Nerd Font Mono ExtraBold";
          position = "5, 5";
          halign = "right";
          valign = "bottom";
        }
        # # Music Player Info # #
        # PLAYER TITLE
        {
          monitor = "DP-1";
          text = ''cmd[update:1000] echo "$(playerctl metadata --format "{{ xesam:title }}" 2>/dev/null | cut -c1-50'';
          color = "rgba(184, 212, 224, 0.8)";
          font_size = 14;
          font_family = "Inter Display Medium";
          position = "180, 120";
          halign = "left";
          valign = "bottom";
        }
        # PLAYER ARTIST
        {
          monitor = "DP-1";
          text = ''cmd[update:1000] echo "$(playerctl metadata --format "{{ xesam:artist }}" 2>/dev/null | cut -c1-50)"'';
          color = "rgba(184, 212, 224, 0.8)";
          font_size = 14;
          font_family = "Inter Display Medium";
          position = "180, 80";
          halign = "left";
          valign = "bottom";
        }
        # PLAYER ALBUM
        {
          monitor = "DP-1";
          text = ''cmd[update:1000] echo "$(playerctl metadata --format "{{ xesam:album }}" 2>/dev/null | cut -c1-50)"'';
          color = "rgba(184, 212, 224, 0.8)";
          font_size = 14;
          font_family = "Inter Display Medium";
          position = "180, 40";
          halign = "left";
          valign = "bottom";
        }
      ];
    };
  };
}
