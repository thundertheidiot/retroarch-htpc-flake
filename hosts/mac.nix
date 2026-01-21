{...}: {
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "26.05";
  time.timeZone = "Europe/Helsinki";

  boot.kernelModules = ["kvm-intel"];
  boot.initrd.availableKernelModules = ["xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci"];

  boot.loader.systemd-boot.enable = true;
}
