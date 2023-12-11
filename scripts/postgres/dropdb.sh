#!/usr/bin/env bash
####################
set -e
####################
readonly DB_NAME="${1}"
####################
check_vars(){
  if [ -z "${DB_NAME}" ]; then printf 'Undefined DB_NAME\n' 1>&2; return 1; fi
  if [ "$DB_NAME" == 'postgres' ]; then printf 'Database postgres should not be deleted\n' 1>&2; return 1; fi
}
check_db_already_exists(){
  if ! su -c "psql -d '${DB_NAME}' -c 'select 1;' > /dev/null 2>&1" ${CONTAINER_USER}; then
    printf "Database ${DB_NAME} does not exist\n"; return 1
  fi
}
drop_db(){
  printf "Are you sure that you want to delete ${DB_NAME} database? (Y/n): "
  read input
  if [ "${input}" != 'Y' ]; then printf 'Abort!\n' 1>&2; return 1; fi
  su -c "psql -d 'postgres' -c 'DROP DATABASE ${DB_NAME};'" ${CONTAINER_USER}
}
####################
check_vars
check_db_already_exists
drop_db
