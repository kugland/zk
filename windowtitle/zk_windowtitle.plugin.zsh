() {
  emulate -LR zsh
  autoload -Uz add-zsh-hook

  # Ellipsize a path to display it in a limited space.
  __zk_windowtitle__ellipsize() {
    emulate -LR zsh
    setopt local_options extended_glob no_sh_word_split

    local -i maxlen
    local -i elm_maxlen
    zstyle -s :plugin:zk_windowtitle dir_maxlen maxlen || maxlen=40
    zstyle -s :plugin:zk_windowtitle elm_maxlen elm_maxlen || elm_maxlen=20

    (( ${#1} < maxlen )) && { REPLY="$1"; return; }

    local -a split=(${(s:/:)1})
    local -a head=()
    local -a tail=()
    local prefix=''
    [[ $1 == /* ]] && prefix='/'
    local -i next=0
    for i in {1..$#split}; do
      (( ${#split[$i]} > $(( elm_maxlen + 3 )) )) && split[$i]=${split[$i]:0:$elm_maxlen}…
    done
    local elm
    while (( ${#:-$prefix${(j:/:)head}/…/${(j:/:)tail}} < $maxlen && $#split )); do
      (( next == 0 )) && { elm=$split[1]; shift split; } || { elm=$split[-1]; shift -p split; }
      (( ${#:-$prefix${(j:/:)head}/$elm/${(j:/:)tail}} > $maxlen && $#elm > 3 )) && elm='…'
      (( next == 0 )) && head+=( $elm ) || tail=( $elm $tail )
      next=$(( !next ))
      [[ $elm = '…' ]] && break
    done
    if (( $#split == 1 && ${#${split[1]}} <= 3 )); then
      head+=($split[1])
    elif (( $#split )); then
      head+=('…')
    fi
    REPLY=${prefix}${(j:/:)head}/${(j:/:)tail}
    while [[ $REPLY = *'/…/…/'* ]]; do REPLY=${REPLY//\/…\/…/\/…}; done
    while [[ $REPLY = *' …'* ]]; do REPLY=${REPLY// …/…}; done
  }

  # Replace control characters with their Unicode representations.
  __zk_windowtitle__replace_cntl() {
    REPLY="$1"
    REPLY=${${${${REPLY//$'\x00'/␀}//$'\x01'/␁}//$'\x02'/␂}//$'\x03'/␃}
    REPLY=${${${${REPLY//$'\x04'/␄}//$'\x05'/␅}//$'\x06'/␆}//$'\x07'/␇}
    REPLY=${${${${REPLY//$'\x08'/␈}//$'\x09'/␉}//$'\x0a'/␊}//$'\x0b'/␋}
    REPLY=${${${${REPLY//$'\x0c'/␌}//$'\x0d'/␍}//$'\x0e'/␎}//$'\x0f'/␏}
    REPLY=${${${${REPLY//$'\x10'/␐}//$'\x11'/␑}//$'\x12'/␒}//$'\x13'/␓}
    REPLY=${${${${REPLY//$'\x14'/␔}//$'\x15'/␕}//$'\x16'/␖}//$'\x17'/␗}
    REPLY=${${${${REPLY//$'\x18'/␘}//$'\x19'/␙}//$'\x1a'/␚}//$'\x1b'/␛}
    REPLY=${${${${REPLY//$'\x1c'/␜}//$'\x1d'/␝}//$'\x1e'/␞}//$'\x1f'/␟}
    REPLY=${REPLY//$'\x7f'/␡}
  }

  __zk_windowtitle__print_title() {
    emulate -LR zsh
    setopt extended_glob

    local REPLY cmd cwd format

    __zk_windowtitle__replace_cntl "${history[$HISTCMD]:-$1}"
    cmd="$REPLY"
    __zk_windowtitle__replace_cntl "${(%):-%~}"
    __zk_windowtitle__ellipsize "$REPLY"
    cwd="$REPLY"

    if (( ! ${+TMUX} )); then
      zstyle -s :plugin:zk_windowtitle format format
      [[ -z $format ]] && format='%1(p.🔓 .)%c • %d'
    else
      zstyle -s :plugin:zk_windowtitle format_tmux format
      [[ -z $format ]] && format='%c'
    fi

    zformat -f REPLY "$format" c:"$cmd" d:"$cwd" p:$(( UID == 0 ))
    print -n '\e]0;'
    print -nr -- "$REPLY"
    print -n '\e\\'
  }

  __zk_windowtitle__precmd() {
    __zk_windowtitle__print_title zsh
  }

  __zk_windowtitle__preexec() {
    emulate -LR zsh

    local cmd="$2"
    local -i maxlen=0
    zstyle -s :plugin:zk_windowtitle cmd_maxlen maxlen
    (( maxlen == 0 )) && maxlen=32
    if (( $#cmd > maxlen )); then
      maxlen=$(( maxlen - 1 ))
      cmd="${cmd[1,$maxlen]}…"
    fi
    __zk_windowtitle__print_title "$cmd"
  }

  zsh-defer -1 __zk_windowtitle__print_title zsh

  add-zsh-hook precmd __zk_windowtitle__precmd
  add-zsh-hook preexec __zk_windowtitle__preexec
}
