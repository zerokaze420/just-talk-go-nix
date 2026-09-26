{ config, lib, pkgs, ... }:

let
  cfg = config.programs.just-talk;
in
{
  options.programs.just-talk = {
    enable = lib.mkEnableOption "Just Talk desktop voice input tool";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./default.nix { };
      defaultText = lib.literalExpression "pkgs.callPackage ./default.nix { }";
      description = "The Just Talk package to install.";
    };

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to start Just Talk automatically with the graphical session.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "--no-tui" ];
      example = [ "--no-tui" "--backend" "wayland" ];
      description = "Extra arguments passed to just-talk when autoStart is enabled.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];

    xdg.desktopEntries.just-talk = {
      name = "Just Talk";
      genericName = "Voice Input";
      comment = "Desktop voice input tool";
      exec = "${cfg.package}/bin/just-talk";
      terminal = true;
      categories = [ "Utility" "AudioVideo" ];
    };

    systemd.user.services.just-talk = lib.mkIf cfg.autoStart {
      Unit = {
        Description = "Just Talk voice input";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = lib.escapeShellArgs ([ "${cfg.package}/bin/just-talk" ] ++ cfg.extraArgs);
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ ];
}
