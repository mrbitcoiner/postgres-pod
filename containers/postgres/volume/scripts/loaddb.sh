#!/usr/bin/env bash
####################
set -e
####################
readonly DB_NAME="${1}"
readonly DUMP_LABEL="${2}"
readonly DUMP_PATH='/app/data/dump'
####################
check_vars(){
  if [ -z "${DB_NAME}" ]; then printf 'Undefined DB_NAME\n' 1>&2; return 1; fi
  if [ -z "${DUMP_LABEL}" ]; then printf 'Undefined DUMP_LABEL\n' 1>&2; return 1; fi
  if [ "$DB_NAME" == 'postgres' ]; then printf 'Database postgres should not be changed\n' 1>&2; return 1; fi
}
check_db_already_exists(){
  if su -c "psql -d '${DB_NAME}' -c 'select 1;' > /dev/null 2>&1" ${CONTAINER_USER}; then
    printf "Database ${DB_NAME} already exists\n"; return 1
  fi
}
drop_db(){
  /app/scripts/createdb.sh "${DB_NAME}"
  su -c "psql ${DB_NAME} < ${DUMP_PATH}/${DUMP_LABEL}" ${CONTAINER_USER}
}
####################
check_vars
check_db_already_exists
drop_db
