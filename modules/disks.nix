{lib, ...}: let
  inherit (lib) mkDefault;
in {
  config = {
    services.udisks2 = {
      enable = true;
      mountOnMedia = true;
    };

    services.devmon.enable = true;
    boot.supportedFilesystems = ["ntfs" "exfat" "vfat" "ext4" "btrfs"];

    fileSystems = {
      "/" = {
        fsType = "tmpfs";
        options = [
          "size=10M"
          "defaults"
          "mode=755"
        ];
      };
      "/boot" = {
        label = mkDefault "HTPC_BOOT";
        fsType = "vfat";
      };
      "/nix" = {
        label = mkDefault "htpc-main";
        fsType = "btrfs";
        options = ["subvol=@nix"];
        neededForBoot = true;
      };
      "/tmp" = {
        label = mkDefault "htpc-main";
        fsType = "btrfs";
        options = ["subvol=@tmp"];
        neededForBoot = true;
      };
      "/var/tmp" = {
        label = mkDefault "htpc-main";
        fsType = "btrfs";
        options = ["subvol=@var_tmp"];
      };
    };
  };
}
