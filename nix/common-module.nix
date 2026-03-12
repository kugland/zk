{lib, ...}: {
  options.programs.zsh.zk = {
    consoleColors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "000000" # black
        "7f0000" # red
        "007f00" # green
        "7f7f00" # yellow
        "00007f" # blue
        "7f007f" # magenta
        "007f7f" # cyan
        "c0c0c0" # white
        "7f7f7f" # bright black
        "ff0000" # bright red
        "00ff00" # bright green
        "ffff00" # bright yellow
        "0000ff" # bright blue
        "ff00ff" # bright magenta
        "00ffff" # bright cyan
        "ffffff" # bright white
      ];
      description = "List of 16 console colors for the sanetty plugin, in hex format (e.g., 'ff0000' for red).";
    };
  };
}
