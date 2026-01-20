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
    };

    users.groups.nixuser = {};

    boot.initrd.systemd.enable = true;

    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = false;
      };
    };

    users.users.root.openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBKwHM/9spQfyeNIl/p8N8XBuoKj8UrhuhhlbEwkrgjZ thunder@disroot.org"];

    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      use-xdg-base-directories = true;
      allow-import-from-derivation = true;
    };
  };
}
