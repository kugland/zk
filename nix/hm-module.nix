{flakePackages}: {
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.programs.zsh.zk;

  inherit (flakePackages."${pkgs.stdenv.hostPlatform.system}") zsh-zk;
in {
  imports = [./common-module.nix];

  options.programs.zsh.zk = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable zk configuration.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.zsh pkgs.gitstatus];
    home.file.".zshrc".text = import ./zshrc.nix {
      inherit pkgs zsh-zk;
      inherit (cfg) consoleColors;
    };
  };
}
