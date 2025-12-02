{
  description = "My NIX configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
  };

  outputs = inputs @ {
    self,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;}
    {
      systems = [
        "i686-linux"
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem = {
        pkgs,
        config,
        ...
      }: {
        packages = {
          zsh-zk = pkgs.callPackage ./nix/package.nix {};
          default = config.packages.zsh-zk;
        };
      };

      flake = let
        flakePackages = self.packages;
      in {
        nixosModules.default = import ./nix/nixos-module.nix {inherit flakePackages;};
        hmModules.default = import ./nix/hm-module.nix {inherit flakePackages;};
      };
    };
}
