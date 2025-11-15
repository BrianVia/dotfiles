#!/usr/bin/env bash
set -e
set -u

if hash pbcopy 2>/dev/null; then
  if [ $# -eq 0 ]; then
    exec pbcopy
  else
    exec pbcopy < "$1"
  fi
elif hash xclip 2>/dev/null; then
  if [ $# -eq 0 ]; then
    exec xclip -selection clipboard
  else
    exec xclip -selection clipboard < "$1"
  fi
elif hash putclip 2>/dev/null; then
  if [ $# -eq 0 ]; then
    exec putclip
  else
    exec putclip < "$1"
  fi
else
  rm -f /tmp/clipboard 2> /dev/null
  if [ $# -eq 0 ]; then
    cat > /tmp/clipboard
  else
    cat "$1" > /tmp/clipboard
  fi
fi
