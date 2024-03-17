#!/usr/bin/env zsh

set -eu

if [ "$(basename "$(ps -p $$ -o exe=)")" != zsh ]; then
  echo "Please run this script with zsh."
  exit 1
fi

set -eux -o pipefail

ANTIDOTE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/antidote"
rm -rf "${ANTIDOTE_DIR}" || true
git clone --depth=1 "https://github.com/mattmc3/antidote.git" "$ANTIDOTE_DIR"
curl -sSL -o ~/.zshrc "https://raw.githubusercontent.com/kugland/zk/master/.zshrc"
curl -sSL -o ~/.zsh_plugins.txt "https://raw.githubusercontent.com/kugland/zk/master/.zsh_plugins.txt"

ZDOTDIR="$HOME" zsh --no-globalrcs
