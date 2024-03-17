setopt interactive_comments no_beep no_correct

() {
  emulate -LR zsh

  # Set local options and load necessary modules and functions
  zmodload zsh/terminfo zsh/zle
  autoload -Uz add-zle-hook-widget

  # Decide which history search widget to use
  local history_search_{backward,forward}
  history_search_backward=history-beginning-search-backward
  history_search_forward=history-beginning-search-forward
  if zstyle -t :plugin:zk_zle use-history-substring-search; then
    history_search_backward=history-substring-search-up
    history_search_forward=history-substring-search-down
  fi

  bindkey -d # Reset key bindings to the default
  bindkey -D emacs viins viopp visual 2> /dev/null # Remove key bindings I don't use

  # Key bindings
  bindkey -M main \
    _ Tab           ${terminfo[ht]:-_}      expand-or-complete \
                    '^I'                    expand-or-complete \
    _ Bksp          ${terminfo[kbs]:-_}     backward-delete-char \
                    '^?'                    backward-delete-char \
    _ Ctrl_Bksp     ${terminfo[cub1]:-_}    backward-delete-word \
                    '^H'                    backward-delete-word \
    _ Ins           ${terminfo[kich1]:-_}   __zk_zle__overwrite_mode_toggle \
                    ${terminfo[kIC]:-_}     __zk_zle__overwrite_mode_toggle \
                    '^[[2~'                 __zk_zle__overwrite_mode_toggle \
    _ Del           ${terminfo[kdch1]:-_}   delete-char \
                    ${terminfo[kDC]:-_}     delete-char \
                    '^[[3~'                 delete-char \
    _ Ctrl_Del      ${terminfo[kDC5]:-_}    delete-word \
                    '^[[3^'                 delete-word \
    _ Home          ${terminfo[khome]:-_}   beginning-of-line \
                    ${terminfo[kHOME]:-_}   beginning-of-line \
                    '^[OH'                  beginning-of-line \
                    '^[[H'                  beginning-of-line \
                    '^[[1;2H'               beginning-of-line \
    _ End           ${terminfo[kend]:-_}    end-of-line \
                    ${terminfo[kEND]:-_}    end-of-line \
                    '^[OF'                  end-of-line \
                    '^[[F'                  end-of-line \
                    '^[[1;2F'               end-of-line \
    _ Ctrl_Home     '^[[1;5H'               __zk_zle__move_to_beginning_of_buffer \
                    '^[[7^'                 __zk_zle__move_to_beginning_of_buffer \
    _ Ctrl_End      '^[[1;5F'               __zk_zle__move_to_end_of_buffer \
                    '^[[8^'                 __zk_zle__move_to_end_of_buffer \
    _ PgUp          ${terminfo[kpp]:-_}     $history_search_backward \
                    ${terminfo[kPRV]:-_}    $history_search_backward \
                    '^[[5~'                 $history_search_backward \
                    '^[[5;5~'               $history_search_backward \
                    '^[[5^'                 $history_search_backward \
    _ PgDn          ${terminfo[knp]:-_}     $history_search_forward \
                    ${terminfo[kNXT]:-_}    $history_search_forward \
                    '^[[6~'                 $history_search_forward \
                    '^[[6;5~'               $history_search_forward \
                    '^[[6^'                 $history_search_forward \
    _ ↑             ${terminfo[kcuu1]:-_}   up-line-or-history \
                    ${terminfo[kUP]:-_}     up-line-or-history \
                    '^[[A'                  up-line-or-history \
    _ ↓             ${terminfo[kcud1]:-_}   down-line-or-history \
                    ${terminfo[kDN]:-_}     down-line-or-history \
                    '^[[B'                  down-line-or-history \
    _ →             ${terminfo[kcuf1]:-_}   forward-char \
                    ${terminfo[kRIT]:-_}    forward-char \
                    '^[[C'                  forward-char \
    _ ←             ${terminfo[kcub1]:-_}   backward-char \
                    ${terminfo[kLFT]:-_}    backward-char \
                    '^[[D'                  backward-char \
    _ Ctrl_←        ${terminfo[kLFT5]:-_}   backward-word \
                    '^[Od'                  backward-word \
    _ Ctrl_→        ${terminfo[kRIT5]:-_}   forward-word \
                    '^[Oc'                  forward-char \
    _ Ctrl_Alt_←    '^[[1;7D'               beginning-of-line \
                    '^[^[Od'                beginning-of-line \
    _ Ctrl_Alt_→    '^[[1;7C'               end-of-line \
                    '^[^[Oc'                end-of-line \
    _ Ctrl_D        '^D'                    __zk_zle__send_break \
    _ Ctrl_F        '^F'                    __zk_zle__insert_files \
    _ Ctrl_L        '^L'                    __zk_zle__clear_screen \
    _ Ctrl_P        '^P'                    copy-prev-shell-word \
    _ Ctrl_R        '^R'                    history-incremental-search-backward \
    _ Ctrl_T        '^T'                    __zk_zle__dirstack \
    _ Ctrl_U        '^U'                    kill-whole-line \
    _ Ctrl_V        '^V'                    __zk_zle__paste \
    _ Ctrl_Y        '^Y'                    redo \
    _ Ctrl_Z        '^Z'                    undo \
    _ Space         ' '                     magic-space \
    _ Paste         '^[[200~'               bracketed-paste \
    _ Enter         '^M'                    accept-line \
                    '^J'                    accept-line \
    _ Ctrl_Enter    '^[[27;5;13~'           accept-and-hold \
    _ Shift_Enter   '^[[27;2;13~'           __zk_zle__add_eol \
                    '^[OM'                  __zk_zle__add_eol \
    _ "Ctrl_'"      '^[[27;5;39~'           quote-line \
    _ "Esc_'"       "^['"                   quote-line \
    _ 'Restore _'   _                       self-insert

  # Widgets used by the key bindings
  __zk_zle__add_eol() { BUFFER="$LBUFFER"$'\n'"$RBUFFER"; CURSOR=$(( CURSOR + 1 )); }
  __zk_zle__send_break() { BUFFER+='^D'; zle send-break; }
  __zk_zle__clear_screen() { print -n $'\e[3J'; zle clear-screen; }
  __zk_zle__move_to_beginning_of_buffer() { CURSOR=0; }
  __zk_zle__move_to_end_of_buffer() { CURSOR=$#BUFFER; }
  zle -N __zk_zle__add_eol
  zle -N __zk_zle__send_break
  zle -N __zk_zle__clear_screen
  zle -N __zk_zle__move_to_beginning_of_buffer
  zle -N __zk_zle__move_to_end_of_buffer

  # Remove the / character from WORDCHARS, will be used for cursor movement by word.
  WORDCHARS=${${WORDCHARS:s#/#}:s#.#}


  # Enable application mode when ZLE inits, disable it when ZLE finishes
  __zk_zle__appmode_line_init() { (( ${+terminfo[smkx]} )) && echoti smkx; }
  __zk_zle__appmode_line_finish() { (( ${+terminfo[rmkx]} )) && echoti rmkx; }
  add-zle-hook-widget line-init __zk_zle__appmode_line_init
  add-zle-hook-widget line-finish __zk_zle__appmode_line_finish


  # Toggle overwrite mode. This will be called by the Insert key.
  __zk_zle__overwrite_mode_toggle() {
    if zstyle -t :plugin:zk_zle overwrite-mode; then
      zstyle :plugin:zk_zle overwrite-mode no
    else
      zstyle :plugin:zk_zle overwrite-mode yes
    fi
    zle __zk_zle__overwrite_mode__line_init
  }

  # Set ZLE to the correct mode and updates the cursor shape
  __zk_zle__overwrite_mode__line_init() {
    emulate -LR zsh

    local mode insert_cursor overwrite_cursor

    zstyle -b :plugin:zk_zle overwrite-mode mode
    case "$mode $ZLE_STATE" in
      yes*insert*|no*overwrite*) zle overwrite-mode ;;
    esac

    # Default cursor shapes
    # insert:    | on xterm, _ on Linux console
    # overwrite: _ on xterm, █ on Linux console
    zstyle -s :plugin:zk_zle insert_cursor insert_cursor || insert_cursor='\e[5 q\e[?2c'
    zstyle -s :plugin:zk_zle overwrite_cursor overwrite_cursor || overwrite_cursor='\e[3 q\e[?6c'

    [[ "$mode" == yes ]] && print -n "$overwrite_cursor" || print -n "$insert_cursor"
  }

  # Restore the cursor shape when the widget is finished
  __zk_zle__overwrite_mode__line_finish() {
    emulate -LR zsh
    local insert_cursor
    zstyle -s :plugin:zk_zle insert_cursor insert_cursor || insert_cursor='\e[5 q\e[?2c'
    print -n "$insert_cursor"
  }

  zle -N __zk_zle__overwrite_mode_toggle
  add-zle-hook-widget line-init __zk_zle__overwrite_mode__line_init
  add-zle-hook-widget line-finish __zk_zle__overwrite_mode__line_finish

  # Other widgets
  autoload -Uz __zk_zle__{dirstack,insert_files,paste}
  zle -N __zk_zle__dirstack
  zle -N __zk_zle__insert_files
  zle -N __zk_zle__paste
}
