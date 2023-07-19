#!/usr/bin/env bash
####################
set -e
####################
readonly DB_NAME="${1}"
readonly DUMP_LABEL="${2}"
readonly DUMP_PATH='/app/data/dump'
####################
mkdirs(){
  mkdir -p ${DUMP_PATH}
  chown -R ${CONTAINER_USER}:${CONTAINER_USER} ${DUMP_PATH}
}
check_vars(){
  if [ -z "${DB_NAME}" ]; then printf 'Undefined DB_NAME\n' 1>&2; return 1; fi
  if [ -z "${DUMP_LABEL}" ]; then printf 'Undefined DUMP_LABEL\n' 1>&2; return 1; fi
}
check_db_already_exists(){
  if ! su -c "psql -d '${DB_NAME}' -c 'select 1;' > /dev/null 2>&1" ${CONTAINER_USER}; then
    printf "Database ${DB_NAME} does not exist\n"; return 1
  fi
}
dump_db(){
  su -c "pg_dump ${DB_NAME} > ${DUMP_PATH}/${DUMP_LABEL}" ${CONTAINER_USER}
  printf "Sucessfully dumped ${DB_NAME} to ${DUMP_PATH}/${DUMP_LABEL}\n"
}
####################
check_vars
mkdirs
check_db_already_exists
dump_db
