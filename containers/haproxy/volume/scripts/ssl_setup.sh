#!/usr/bin/env bash
####################
set -e
####################
readonly ADMINER_CERT_DIR="/app/data/certs/adminer"
####################

/app/scripts/ssl_config.sh adminer

if ! [ -e "${ADMINER_CERT_DIR}/server.pem" ]; then
  cat ${ADMINER_CERT_DIR}/server.crt ${ADMINER_CERT_DIR}/server.key > ${ADMINER_CERT_DIR}/server.pem 
fi

su -c '/app/scripts/ssl_config.sh adminer' ${CONTAINER_USER}


