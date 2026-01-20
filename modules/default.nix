{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkForce;
in {
  imports = [
    ./disks.nix
    ./impermanence.nix
    ./retroarch.nix
  ];

  config = {
    users.users.nixuser = {
      isNormalUser = true;
      group = "nixuser";
      password = "password";
      extraGroups = ["wheel"];
    };

    console.enable = false;
    systemd.enableEmergencyMode = false;

    boot = {
      initrd.systemd.enable = true;
      initrd.kernelModules = ["virtio_gpu"];

      consoleLogLevel = 0;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "loglevel=3"
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
      ];

      loader.timeout = mkForce 0;

      plymouth = {
        enable = true;
        themePackages = [pkgs.plymouth-blahaj-theme];
        theme = "blahaj";
      };
    };

    users.groups.nixuser = {};

    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      use-xdg-base-directories = true;
      allow-import-from-derivation = true;
    };

    nixpkgs.config.allowUnfree = true;
  };
}
