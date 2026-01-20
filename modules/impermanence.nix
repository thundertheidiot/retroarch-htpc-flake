{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge isString;
  inherit (lib.options) mkOption;
  inherit (lib.lists) flatten;
  inherit (lib.strings) concatStringsSep replaceStrings;
  inherit (lib.attrsets) filterAttrs mapAttrsToList listToAttrs;
  inherit (lib.types) listOf bool str attrs either;

  cfg = config.my.impermanence;
in {
  options = {
    my.impermanence = {
      enable = mkOption {
        type = bool;
        default = true;
        description = "Enable impermanence";
      };

      persist = mkOption {
        type = str;
        default = "/nix/persist";
        description = "Directory to use for persistance of files.";
      };

      directories = mkOption {
        type = listOf (either attrs str);
        default = [];
        apply = let
          mkDir' = {
            path,
            persistPath ? "${cfg.persist}/rootfs/${path}",
            permissions ? "1777",
            user ? "root",
            group ? "root",
            wantedBy ? [],
            before ? [],
          }: {
            inherit path persistPath permissions user group wantedBy before;
          };

          mkDir = dir:
            if isString dir
            then mkDir' {path = dir;}
            else mkDir' dir;
        in
          list: map mkDir list;
        description = "Directories to persist across reboots.";
      };

      files = mkOption {
        type = listOf (either attrs str);
        default = [];
        apply = let
          mkFile' = {
            path,
            persistPath ? "${cfg.persist}/rootfs/${path}",
            permissions ? "1777",
            user ? "root",
            group ? "root",
            wantedBy ? [],
            before ? [],
          }: {
            inherit path persistPath permissions user group wantedBy before;
          };

          mkFile = file:
            if isString file
            then mkFile' {path = file;}
            else mkFile' file;
        in
          list: map mkFile list;
        description = "Files to persist across reboots.";
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      my.impermanence.directories = [
        {
          path = "/var/log";
          permissions = "711";
        }
        "/var/lib/systemd"
      ];
    })

    # Create and mount directories
    (mkIf cfg.enable {
      systemd.mounts = map (dir:
        with dir; {
          where = path;
          what = persistPath;
          type = "none";
          options = "bind,X-fstrim.notrim,x-gvfs-hidden";

          before = ["graphical.target"] ++ before;
          wantedBy = ["graphical.target"] ++ wantedBy;
        })
      cfg.directories;

      systemd.tmpfiles.rules = flatten (map (dir:
        with dir; [
          "d ${persistPath} ${permissions} ${user} ${group} - -"
          "d ${path} ${permissions} ${user} ${group} - -"
        ])
      cfg.directories);
    })
    # Create and mount directories
    (mkIf cfg.enable {
      boot.postBootCommands =
        concatStringsSep " "
        (map (file:
          with file; ''
            if [ -e "${persistPath}" ] || [ -L "${persistPath}" ]; then
              cp -P "${persistPath}" "${path}"
            fi
          '')
        cfg.files);

      systemd.services = listToAttrs (map
        (file:
          with file; let
            name = "persist-${replaceStrings ["/"] ["_"] path}";
          in {
            inherit name;
            value = {
              wantedBy = ["graphical.target"];
              path = [pkgs.util-linux];
              unitConfig.defaultDependencies = true;
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                # Service is stopped before shutdown
                ExecStop = pkgs.writeShellScript name ''
                  mkdir --parents "$(dirname ${persistPath})"
                  cp -P "${path}" "${persistPath}"
                '';
              };
            };
          })
        cfg.files);
    })

    ### fixes/hacks

    # home directories
    (mkIf cfg.enable {
      systemd.tmpfiles.rules =
        mapAttrsToList
        (name: user: "d ${user.home} 0700 ${name} ${user.group} - -")
        (filterAttrs (_name: attrs: attrs.createHome) config.users.users);
    })

    # machine id
    (mkIf cfg.enable {
      environment.etc = listToAttrs (map (loc: {
        name = loc;
        value = {source = "${cfg.persist}/rootfs/etc/${loc}";};
      }) ["machine-id"]);
    })
  ];
}
