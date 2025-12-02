{flakePackages}: {
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.programs.zsh.zk;

  inherit (flakePackages."${pkgs.system}") zsh-zk;
in {
  options.programs.zsh.zk = {
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of users to apply the zk configuration to.";
    };
  };

  config = lib.mkIf (lib.length cfg.users > 0) {
    environment.systemPackages = [pkgs.zsh pkgs.gitstatus];
    system.activationScripts.zsh-zk-install = lib.mkIf (lib.length cfg.users > 0) (
      let
        zshrc = pkgs.writeText "zk-zshrc" (import ./zshrc.nix {inherit pkgs zsh-zk;});
        targets = map (user: "${config.users.users.${user}.home}/.zshrc") cfg.users;
      in
        lib.concatStringsSep "\n" (
          map (target: "ln -sf ${zshrc} ${lib.escapeShellArg [target]}") targets
        )
    );
  };
}
