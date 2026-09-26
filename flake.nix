{
  description = "Just Talk desktop voice input tool";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.callPackage ./default.nix { };
          just-talk = self.packages.${system}.default;
        });

      overlays.default = final: prev: {
        just-talk = final.callPackage ./default.nix { };
      };

      nixosModules.default = import ./nixos-module.nix;
      homeManagerModules.default = import ./hm-module.nix;
    };
}
