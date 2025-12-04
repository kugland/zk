{
  pkgs,
  zsh-zk,
}: ''
  zstyle :plugin:zk_zle use-history-substring-search yes

  if [[ $TERM = linux ]]; then
    zstyle :plugin:zk_sanetty reset-extra \
      '\e]P0181716\e\\' '\e]P1c74f49\e\\' '\e]P251c236\e\\' '\e]P3c4903b\e\\' \
      '\e]P4648ecf\e\\' '\e]P5b475ca\e\\' '\e]P63bc4bf\e\\' '\e]P7ccc8c4\e\\' \
      '\e]P883827b\e\\' '\e]P9ff7068\e\\' '\e]Pa7fff57\e\\' '\e]Pbffbf57\e\\' \
      '\e]Pc7db7ff\e\\' '\e]Pddf91f4\e\\' '\e]Pe57fffc\e\\' '\e]Pfffffff\e\\'
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
