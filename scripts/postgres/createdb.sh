#!/usr/bin/env bash
####################
set -e
####################
readonly DB_NAME="${1}"
####################
check_vars(){
  if [ -z "${DB_NAME}" ]; then printf 'Undefined DB_NAME\n' 1>&2; return 1; fi
}
check_db_already_exists(){
  if su -c "psql -d '${DB_NAME}' -c 'select 1;' > /dev/null 2>&1" ${CONTAINER_USER}; then
    printf "Database ${DB_NAME} already exists\n"; return 1
  fi
}
create_db(){
  su -c "psql -d 'postgres' -c 'CREATE DATABASE ${DB_NAME};'" ${CONTAINER_USER}
}
####################
check_vars
check_db_already_exists
create_db
