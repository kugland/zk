() {
  emulate -LR zsh
  zmodload zsh/parameter
  autoload -Uz add-zsh-hook

  __zk_git__precmd() {
    emulate -LR zsh
    setopt local_options no_sh_word_split

    (( ${+commands[git]} && ${+functions[gitstatus_start]} )) || return 0

    typeset -g __zk_git__status=''

    () {
      local curdir="${PWD:A}"
      while [[ "$curdir" != "/" ]]; do        # Scan up the directory tree.
        [[ -d "$curdir/.git" ]] && break      # Stop once we find a git repo.
        curdir="${curdir:h}"                  # Go up one level.
      done
      [[ ! -d "$curdir/.git" ]] && return 1   # Not a git repo.
      return 0                                # It's a git repo.
    } && {
      (( $__zk_git__last_active == 0 )) && gitstatus_start -e -{s,u,c,d}-1 -t0.2 -m5000 MY
      __zk_git__last_active=$EPOCHSECONDS

      gitstatus_query 'MY'             || return 1
      [[ $VCS_STATUS_RESULT == ok-* ]] || return 0

      local -A styles
      local identifier

      zstyle -s :plugin:zk_git identifier identifier \
        && zstyle -a :plugin:zk_git styles styles \
        || {
          # If the styles are unset, we will assume the user doesn't want gitstatus, so we'll
          # stop it if it's running. This will happen when switching to zk minimal theme.
          if (( __zk_git__last_active != 0 )); then
            gitstatus_stop MY
            __zk_git__last_active=0
          fi
          return 1
        }

      local p=" $identifier"
      local where
      if [[ -n "$VCS_STATUS_LOCAL_BRANCH" ]]; then
        p+=' '
        where="$VCS_STATUS_LOCAL_BRANCH"
      elif [[ -n "$VCS_STATUS_TAG" ]]; then
        p+="$ {styles[WHERE_TAG]}"
        where="$VCS_STATUS_TAG"
      else
        p+=" ${styles[WHERE_COMMIT]}"
        where="${VCS_STATUS_COMMIT[1,8]}"
      fi
      (( $#where > 32 )) && where[13,-13]="…"
      p+="${where//\%/%%}"
      local s
      for s in {STASHES,NUM_{{,UN}STAG,UNTRACK,CONFLICT}ED,{,PUSH_}COMMITS_{BEHIND,AHEAD},ACTION}
      do
        local value="${(P)${:-VCS_STATUS_$s}}"
        [[ -n $value && $value != 0 ]] && p+=" ${styles[$s]}${value}%b%f"$'%{\e[0m%}'
      done
      if (( VCS_STATUS_HAS_UNTRACKED == -1
         || VCS_STATUS_HAS_UNSTAGED == -1
         || VCS_STATUS_HAS_CONFLICTED == -1 )); then
        p+=" ${styles[LARGE_REPO]}"
      fi

      __zk_git__status="$p"
    }
  }

  __zk_git__periodic() {
    emulate -LR zsh
    if (( $EPOCHSECONDS > ($__zk_git__last_active + 600) )); then
      __zk_git__last_active=0
      gitstatus_stop MY
    fi
  }

  typeset -gi __zk_git__last_active=0
  add-zsh-hook precmd __zk_git__precmd
  add-zsh-hook periodic __zk_git__periodic
}
