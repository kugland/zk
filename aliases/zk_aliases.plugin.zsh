() {
  emulate -LR zsh
  zmodload zsh/parameter

  if (( ${+commands[eza]} )); then
    alias ls='command eza -h --icons=auto --color=auto --group-directories-first'
  else
    alias ls='command ls -h -p --color=auto --group-directories-first --time-style=long-iso'
  fi
  alias diff='command diff --color=auto'
  alias ip='command ip --color=auto'
  alias rm='command rm -I'  # Ask for confirmation when deleting more than 3 files

  autoload -Uz __zk_dircolors
  __zk_dircolors
  unhash -f __zk_dircolors

  # Add colors to grep and friends.
  local grep
  for grep in {{,bz,lz,zstd,xz}{,e,f},pcre{,2}}grep
  do
    (( ${+commands[$grep]} )) && alias "$grep=command $grep --color=auto"
  done

  # Alias python to python3 when not python doesn't exist
  (( ! ${+commands[python]} && ${+commands[python3]} )) && alias python=python3

  # Some aliases I like
  alias isodate='date +%Y-%m-%d'
  alias isotime='date +%H:%M:%S'
  alias isodate_utc='date -u +%Y-%m-%d'
  alias isotime_utc='date -u +%H:%M:%S'
  alias supernice='ionice -c3 nice -n19 --'

  # Autoloaded functions
  autoload -Uz detach dockersh nmed tmux
}
