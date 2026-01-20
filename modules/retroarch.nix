{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) getExe attrValues filter;
  inherit (lib.meta) availableOn;
in {
  config = {
    my.impermanence.directories = [
      {
        path = "${config.users.users.nixuser.home}/.config/retroarch";
        user = "nixuser";
        group = "nixuser";
        permissions = "700";
      }
      {
        path = "${config.users.users.nixuser.home}/.cache/retroarch";
        user = "nixuser";
        group = "nixuser";
        permissions = "700";
      }
    ];

    services.cage = {
      enable = true;

      program = pkgs.writeShellScript "retroarch-runner" (let
        retroarch = getExe (pkgs.retroarch-bare.wrapper {
          cores = filter (c: (c ? libretroCore) && (availableOn pkgs.stdenv.hostPlatform c)) (attrValues pkgs.libretro);
          settings = {
            menu_driver = "rgui";
            rgui_menu_color_theme = "6";
            rgui_particle_effect = "5";
            rgui_browser_directory = "/media";
            cache_directory = "~/.cache/retroarch";

            content_show_images = "false";
            content_show_music = "false";
            content_show_video = "false";
            content_show_netplay = "false";
            content_show_playlists = "false";
            content_show_playlist_tabs = "false";

            menu_show_configurations = "false";
            menu_show_core_updater = "false";
            menu_show_online_updater = "false";
            menu_show_dump_disc = "false";
            menu_show_help = "false";
            menu_show_information = "false";

            desktop_menu_enable = "false";
          };
        });
      in ''
        while ! ${retroarch}; do
          echo "Retroarch failed with $?, restarting"
          sleep 1
        done

        poweroff
      '');

      user = "nixuser";
    };
  };
}
