#!/bin/dumb-init /bin/bash

if [ "${1:0:1}" = '-' ]; then
    set -- tmux "$@"
fi

if [ "$1" = 'server' ]; then
  tmux -v new-session -s console -d
  while true; do
    sleep 1
    tmux list-sessions > /dev/null 2>&1 || break
  done
  exit 0
fi

if [ "$1" = 'client' ]; then
  exec tmux -2 att
fi

exec "$@"
