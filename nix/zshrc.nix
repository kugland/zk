{
  pkgs,
  lib ? pkgs.lib,
  zsh-zk,
  consoleColors,
}: let
  colors = lib.lists.imap0 (i: color: "'\\e]P${lib.toHexString i}${color}\\e\\\\'") consoleColors;
in ''
  zstyle :plugin:zk_zle use-history-substring-search yes

  if [[ $TERM = linux ]]; then
    zstyle :plugin:zk_sanetty reset-extra ${lib.concatStringsSep " " colors}
  else
    zstyle -d :plugin:zk_sanetty reset-extra
  fi

  source ${pkgs.zsh-defer}/share/zsh-defer/zsh-defer.plugin.zsh
  fpath+=(
    ${pkgs.zsh-completions}/share/zsh/site-functions
    ${zsh-zk}/share/zsh/plugins/zk/aliases
    ${zsh-zk}/share/zsh/plugins/zk/prompt
    ${zsh-zk}/share/zsh/plugins/zk/sanetty
    ${zsh-zk}/share/zsh/plugins/zk/zle
  )

  zsh-defer source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
  zsh-defer source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
  zsh-defer source ${pkgs.gitstatus}/share/gitstatus/gitstatus.plugin.zsh
  zsh-defer source ${pkgs.zsh-nix-shell}/share/zsh-nix-shell/nix-shell.plugin.zsh

  source ${zsh-zk}/share/zsh/plugins/zk/zle/zk_zle.plugin.zsh
  source ${zsh-zk}/share/zsh/plugins/zk/history/zk_history.plugin.zsh
  zsh-defer source ${zsh-zk}/share/zsh/plugins/zk/aliases/zk_aliases.plugin.zsh
  zsh-defer source ${zsh-zk}/share/zsh/plugins/zk/completion/zk_completion.plugin.zsh
  zsh-defer source ${zsh-zk}/share/zsh/plugins/zk/gitstatus/zk_gitstatus.plugin.zsh
  zsh-defer source ${zsh-zk}/share/zsh/plugins/zk/sanetty/zk_sanetty.plugin.zsh
  zsh-defer source ${zsh-zk}/share/zsh/plugins/zk/windowtitle/zk_windowtitle.plugin.zsh

  autoload -Uz promptinit
  promptinit
  setopt transient_rprompt
  prompt zk fancy
''
