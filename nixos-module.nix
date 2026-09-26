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
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];

    boot.kernelModules = [ "uinput" ];

    hardware.uinput.enable = lib.mkDefault true;
  };

  meta.maintainers = with lib.maintainers; [ ];
}
