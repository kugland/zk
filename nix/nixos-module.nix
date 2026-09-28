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
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of users to apply the zk configuration to.";
    };
  };

  config = lib.mkIf (lib.length cfg.users > 0) {
    environment.systemPackages = [pkgs.zsh pkgs.gitstatus];
    # Use tmpfiles instead of an activation script: activation runs before
    # systemd mounts non-boot filesystems, so a separate /home would hide the link.
    systemd.tmpfiles.rules = let
      zshrc = pkgs.writeText "zk-zshrc" (import ./zshrc.nix {
        inherit pkgs zsh-zk;
        inherit (cfg) consoleColors;
      });
    in
      map (user: "L+ ${config.users.users.${user}.home}/.zshrc - - - - ${zshrc}") cfg.users;
  };
}
