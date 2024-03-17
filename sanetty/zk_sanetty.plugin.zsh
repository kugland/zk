() {
  emulate -LR zsh
  zmodload zsh/terminfo
  autoload -Uz add-zsh-hook is-at-least __zk_sanetty__reset

  # If the terminal supports 256 colors, but not truecolor, load the nearcolor module
  if [[ ${terminfo[colors]} -eq 256 && $COLORTERM != (truecolor|24bit) ]]; then
    is-at-least '5.7.0' $ZSH_VERSION && zmodload zsh/nearcolor 2>/dev/null
  fi

  zsh-defer -1 __zk_sanetty__reset
  add-zsh-hook precmd __zk_sanetty__reset
}
