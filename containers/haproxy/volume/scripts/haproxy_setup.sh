#!/usr/bin/env bash
####################
set -e
####################
readonly CFG_DIR="/app/data/haproxy"
####################

/app/scripts/haproxy_config.sh

su -c "haproxy -f ${CFG_DIR}/haproxy.conf" ${CONTAINER_USER}

