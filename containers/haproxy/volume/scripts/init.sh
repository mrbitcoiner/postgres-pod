#!/usr/bin/env bash
#####################
set -e
#####################

/app/scripts/ssl_setup.sh
/app/scripts/haproxy_setup.sh

