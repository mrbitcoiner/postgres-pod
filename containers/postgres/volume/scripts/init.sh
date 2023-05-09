#!/usr/bin/env bash
####################
set -e
####################

chown -R ${POSTGRES_USER} /app

su -c "docker-entrypoint.sh postgres" ${POSTGRES_USER} &

if [ -e /app/scripts/custom.sh ]; then
  /app/scripts/custom.sh
fi

tail -f /dev/null
