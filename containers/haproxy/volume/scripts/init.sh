#!/usr/bin/env bash
#####################
set -e
#####################

chown -R ${CONTAINER_USER} /app

/app/scripts/ssl_setup.sh
/app/scripts/haproxy_setup.sh

