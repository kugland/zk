local -a OPTS=(
  append_history        # Append to history file, don't overwrite it.
  extended_history      # Timestamp and duration in history entries.
  hist_ignore_all_dups  # Don't record duplicate commands in history.
  hist_ignore_space     # Don't record commands starting with a space.
  hist_no_functions     # Don't record functions in history.
  hist_reduce_blanks    # Remove extra spaces from history.
  hist_verify           # History expansion just loads line.
  no_hist_beep          # Don't beep when searching history.
  share_history         # Share history between multiple shells.
)
[[ $OSTYPE = linux-* ]] && OPTS+=( hist_fcntl_lock )  # Use fcntl() to lock the history file.
setopt ${OPTS[@]}

HISTSIZE=10000  # Maximum number of history entries in memory.
SAVEHIST=99999  # Number of history entries to save to file.

HISTFILE="${XDG_RUNTIME_DIR:-/tmp}/zsh-$UID-history" # Set history file.

__zk_history__create_histfile() {
  zmodload -mF zsh/files b:zf_chmod b:zf_chown
  : >>$HISTFILE                 # Create the history file.
  zf_chmod 0600 $HISTFILE       # Set permissions to 600.
  zf_chown $UID:$GID $HISTFILE  # Set ownership to the user.
}

zsh-defer __zk_history__create_histfile
