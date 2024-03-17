zstyle ':antidote:bundle' use-friendly-names on

. "${XDG_DATA_HOME:-$HOME/.local/share}/antidote/antidote.zsh"

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

antidote load

if [[ ${+commands[nix-shell]} ]]; then
  zsh-defer source ~/.cache/antidote/chisui/zsh-nix-shell/nix-shell.plugin.zsh
fi

autoload -Uz promptinit
promptinit
setopt transient_rprompt
prompt zk fancy
