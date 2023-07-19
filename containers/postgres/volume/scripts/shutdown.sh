#!/usr/bin/env bash
####################
set -e
####################
shutdown(){
  kill -2 $(cat /app/data/postgres.pid)
}
shutdown_loop(){
  while kill -0 $(cat /app/data/postgres.pid) >/dev/null 2>&1; do
    sleep 1
  done
}
####################
shutdown
shutdown_loop

