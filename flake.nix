{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: {
    nixosConfigurations = let
      mkSystem = cfg:
        inputs.nixpkgs.lib.nixosSystem {
          modules = [
            cfg
            ./modules
          ];
        };
    in {
      mac = mkSystem (import ./hosts/mac.nix);
    };
  };
}
