{
  config,
  lib,
  ...
}: {
  services.homepage-dashboard = {
    enable = true;
    listenPort = 8082;
    # API keys for the widgets below, as HOMEPAGE_VAR_* variables
    environmentFile = config.age.secrets.homepage-env.path;

    settings = {
      title = "Homelab";
      theme = "dark";
      headerStyle = "clean";
      layout = [
        {
          Media = {
            style = "row";
            columns = 2;
          };
        }
        {
          Infrastructure = {
            style = "row";
            columns = 2;
          };
        }
      ];
    };

    services = [
      {
        # Icons are from https://dashboardicons.com/
        Media = [
          {
            Jellyfin = {
              description = "Media server";
              href = "http://127.0.0.1:8096";
              icon = "jellyfin.png";
              widget = {
                type = "jellyfin";
                url = "http://127.0.0.1:8096";
                key = "{{HOMEPAGE_VAR_JELLYFIN_KEY}}";
                version = 2; # required for Jellyfin >= 10.12
                enableBlocks = true;
                enableNowPlaying = true;
              };
            };
          }
          {
            "Shoko Server" = {
              description = "Anime library manager";
              href = "http://127.0.0.1:8111";
              icon = "shokoanime.png";
            };
          }
          {
            Sonarr = {
              description = "Sonarr server";
              href = "http://127.0.0.1:8989";
              icon = "sonarr.png";
              widget = {
                type = "sonarr";
                url = "http://127.0.0.1:8989";
                key = "{{HOMEPAGE_VAR_SONARR_KEY}}";
              };
            };
          }
          {
            Radarr = {
              description = "Radarr server";
              href = "http://127.0.0.1:7878";
              icon = "radarr.png";
              widget = {
                type = "radarr";
                url = "http://127.0.0.1:7878";
                key = "{{HOMEPAGE_VAR_RADARR_KEY}}";
              };
            };
          }
          {
            Prowlarr = {
              description = "Prowlarr server";
              href = "http://localhost:9696";
              icon = "prowlarr.png";
              widget = {
                type = "prowlarr";
                url = "http://127.0.0.1:9696";
                key = "{{HOMEPAGE_VAR_PROWLARR_KEY}}";
              };
            };
          }
          {
            Jackett = {
              description = "Torrent indexer proxy";
              href = "http://127.0.0.1:9117";
              icon = "jackett.png";
              widget = {
                type = "jackett";
                url = "http://127.0.0.1:9117";
                # the widget authenticates with the admin password, not the API key
                password = "{{HOMEPAGE_VAR_JACKETT_PASSWORD}}";
              };
            };
          }
          {
            Seerr = {
              description = "Media requests";
              href = "http://127.0.0.1:5055";
              icon = "jellyseerr.png";
              widget = {
                type = "jellyseerr";
                url = "http://127.0.0.1:5055";
                key = "{{HOMEPAGE_VAR_SEERR_KEY}}";
              };
            };
          }
        ];
      }
      {
        Infrastructure = [
          {
            i2pd = {
              description = "I2P router console";
              href = "http://127.0.0.1:7070";
              icon = "i2p.png";
            };
          }
        ];
      }
    ];

    widgets = [
      {
        resources = {
          cpu = true;
          memory = true;
          disk = "/";
        };
      }
      {
        search = {
          provider = "duckduckgo";
          target = "_blank";
        };
      }
    ];
  };

  # The decrypted secret keeps the same path, so restart homepage when its contents change
  systemd.services.homepage-dashboard.restartTriggers = [config.age.secrets.homepage-env.file];
}
