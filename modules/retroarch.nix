{...}: {
  config = {
    services.xserver.enable = true;

    services.displayManager.sddm = {
      enable = true;
      settings = {
        Autologin = {
          Session = "RetroArch.desktop";
          User = "nixuser";
        };
      };
    };

    services.xserver.desktopManager.retroarch.enable = true;
  };
}
