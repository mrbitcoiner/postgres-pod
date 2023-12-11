#!/usr/bin/env bash
####################
set -e
####################
readonly DB_NAME="${1}"
readonly DUMP_LABEL="${2}"
readonly DUMP_PATH='/data/dump'
####################
mkdirs(){
  mkdir -p ${DUMP_PATH}
}
check_vars(){
  if [ -z "${DB_NAME}" ]; then printf 'Undefined DB_NAME\n' 1>&2; return 1; fi
  if [ -z "${DUMP_LABEL}" ]; then printf 'Undefined DUMP_LABEL\n' 1>&2; return 1; fi
}
check_db_already_exists(){
  if ! psql -d "${DB_NAME}" -c "select 1;" > /dev/null 2>&1; then
    printf "Database ${DB_NAME} does not exist\n"; return 1
  fi
}
rename_if_dump_already_exists(){
  if [ -e "${DUMP_PATH}/${DUMP_LABEL}" ]; then 
		mv ${DUMP_PATH}/${DUMP_LABEL} ${DUMP_PATH}/${DUMP_LABEL}.old
  fi
}
dump_db(){
  pg_dump ${DB_NAME} > ${DUMP_PATH}/${DUMP_LABEL}
  printf "Successfully dumped ${DB_NAME} to ${DUMP_PATH}/${DUMP_LABEL}\n"
}
####################
check_vars
mkdirs
check_db_already_exists
rename_if_dump_already_exists
dump_db
