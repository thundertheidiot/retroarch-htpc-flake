{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) getExe attrValues;
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
          cores = with pkgs.libretro; [
            bsnes
            mgba
          ];
          settings = {
            menu_driver = "rgui";
            rgui_menu_color_theme = "6";
            rgui_particle_effect = "5";
            rgui_browser_directory = "/media";
            cache_directory = "~/.cache/retroarch";
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
