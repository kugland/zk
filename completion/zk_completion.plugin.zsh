() {
  emulate -L zsh
  zmodload zsh/parameter
  zmodload -mF zsh/files b:zf_chmod b:zf_chown b:zf_mkdir

  local xdg_cache_home=${XDG_CACHE_HOME:-$HOME/.cache}
  local zcompdump="${xdg_cache_home}/zcompdump"
  local zcompdump_mtime=$( [[ -e "$zcompdump" ]] && zstat +mtime "$zcompdump" || print 0 )
  local zcompcache="${xdg_cache_home}/zcompcache"
  zf_mkdir -p $zcompcache
  zf_chmod 0700 $zcompcache
  zf_chown $UID:$GID $zcompcache

  if (( (EPOCHSECONDS - zcompdump_mtime) > 86400 )); then
    compinit -d $zcompdump
  else
    compinit -C -d $zcompdump
  fi
  zf_chmod 0600 $zcompdump
  zf_chown $UID:$GID $zcompdump

  zstyle ':completion:*' use-cache yes
  zstyle ':completion:*' cache-path $zcompcache

  # General completion settings
  zstyle ':completion:*' completer _complete _prefix
  zstyle ':completion:*' add-space true
  zstyle ':completion:*' menu select
  zstyle ':completion:*:commands' rehash 1
  zstyle ':completion:*:warnings' format '%B%F{red}No matches for %d.%f%b'
  zstyle ':completion:*:matches' group yes
  zstyle ':completion:*:descriptions' format '%B%K{cyan}%F{white}  %d  %f%k%b'
  zstyle ':completion:*' group-name ''
  zstyle ':completion:*' accept-exact '*(N)'

  # Files
  zstyle -e ':completion:*:default' list-colors 'reply="$LS_COLORS"'
  zstyle ':completion:*' list-dirs-first yes

  # Processes
  zstyle ':completion:*:processes' menu yes select
  zstyle ':completion:*:processes' force-list always
  if (( UID == 0 )); then
    zstyle ':completion:*:processes' command 'ps -eo pid=,user=,cmd=| sort -n'
    zstyle ':completion:*:processes-names' command "ps -eo exe= |sed -e 's,^.*/,,g' |sort -f |uniq"
  else
    zstyle ':completion:*:processes' command "ps -u $UID -o pid=,cmd=| sort -n"
    zstyle ':completion:*:processes-names' command "ps -u $UID -o exe= |sed -e 's,^.*/,,g' |sort -f |uniq"
  fi
  zstyle ':completion:*:processes' sort no
  zstyle ':completion:*:processes' list-colors "=(#b) #([0-9]#)*=0=01;32"
  zstyle ':completion:*:processes-names' list-colors '=*=01;32'

  # ssh, scp, sftp and sshfs
  # Load ssh hosts from ~/.ssh/config
  if [[ -r ~/.ssh/config ]]; then
    local ssh_hosts='
      typeset -a reply
      reply=( $(sed -n '\''/^Host\s*/{s///g;s/*//g;s/ /\n/g; p};'\'' <~/.ssh/config | sort) );
    '
    zstyle -e ':completion:*:scp:*' hosts $ssh_hosts
    zstyle -e ':completion:*:sftp:*' hosts $ssh_hosts
    zstyle -e ':completion:*:ssh:*' hosts $ssh_hosts
    zstyle -e ':completion:*:sshfs:*' hosts $ssh_hosts
  fi
  # Don't complete users for ssh, scp, sftp and sshfs
  zstyle ':completion:*:scp:*' users ''
  zstyle ':completion:*:sftp:*' users ''
  zstyle ':completion:*:ssh:*' users ''
  zstyle ':completion:*:sshfs:*' users ''
  # Workaround for sshfs
  [[ -n ${commands[sshfs]} ]] && _user_at_host() { _ssh_hosts "$@"; }
  # Don't complete hosts from /etc/hosts
  zstyle -e ':completion:*' hosts 'reply=()'

  # Hide entries from completion
  zstyle ':completion:*:parameters' ignored-patterns '_*'
  zstyle ':completion:*:functions' ignored-patterns '_*'
  zstyle ':completion:*' single-ignored show
}
