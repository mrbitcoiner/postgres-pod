#!/usr/bin/env bash
####################
set -e
####################
readonly DB_NAME="${1}"
readonly DUMP_LABEL="${2}"
readonly DUMP_PATH='/data/dump'
####################
check_vars(){
  if [ -z "${DB_NAME}" ]; then printf 'Undefined DB_NAME\n' 1>&2; return 1; fi
  if [ -z "${DUMP_LABEL}" ]; then printf 'Undefined DUMP_LABEL\n' 1>&2; return 1; fi
  if [ "$DB_NAME" == 'postgres' ]; then printf 'Database postgres should not be changed\n' 1>&2; return 1; fi
}
check_db_already_exists(){
  if psql -d "${DB_NAME}" -c "select 1;" > /dev/null 2>&1; then
    printf "Database ${DB_NAME} already exists\n"; return 1
  fi
}
load_db(){
  if ! [ -e "${DUMP_PATH}/${DUMP_LABEL}" ]; then printf "Dump file ${DUMP_PATH}/${DUMP_LABEL} does not exist\n" 1>&2; return 1; fi
  /static/scripts/postgres/createdb.sh "${DB_NAME}"
  psql ${DB_NAME} < ${DUMP_PATH}/${DUMP_LABEL}
}
####################
check_vars
check_db_already_exists
load_db
