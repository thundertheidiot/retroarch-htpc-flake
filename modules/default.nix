{...}: {
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

    users.groups.nixuser = {};

    boot.initrd.systemd.enable = true;

    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      use-xdg-base-directories = true;
      allow-import-from-derivation = true;
    };
  };
}
