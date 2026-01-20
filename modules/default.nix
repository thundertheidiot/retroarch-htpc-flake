{...}: {
  imports = [
    ./retroarch.nix
  ];

  config = {
    users.users.nixuser = {
      isNormalUser = true;
      group = "nixuser";
    };

    users.groups.nixuser = {};

    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      use-xdg-base-directories = true;
      allow-import-from-derivation = true;
    };
  };
}
