#!/usr/bin/env bash
####################
set -e
####################
readonly DB_NAME="${1}"
readonly SCHEDULE_TYPE="${2}"
readonly DUMP_PATH='/app/data/dump'
readonly CONFIG_PATH='/app/data/config/dump/schedule'
####################
mkdirs(){
  su -c "mkdir -p ${CONFIG_PATH}" ${CONTAINER_USER}
}
check_input(){
  if [ -z "${DB_NAME}" ] || [ -z "${SCHEDULE_TYPE}" ]; then printf 'Expected: [database] [schedule type]\n' 1>&2; return 1; fi
}
check_schedule_type(){
  case ${SCHEDULE_TYPE} in
    monthly) ;;
    weekly) ;;
    daily) ;;
    daily_twice) ;;
    hourly) ;;
    *) printf 'Schedule types: [ monthly | weekly | daily | daily_twice | hourly ]\n' 1>&2; return 1 ;;
  esac
}
check_schedule_exists(){
  if ! [ -e ${CONFIG_PATH}/${SCHEDULE_TYPE} ]; then return 0; fi
  local schedules=($(cat ${CONFIG_PATH}/${SCHEDULE_TYPE}))
  if [ -z "${schedules}" ]; then return 0; fi
  for i in "${schedules[@]}"; do
    if [ "${i}" == "${DB_NAME}" ]; then printf "${SCHEDULE_TYPE} already set for ${DB_NAME}\n" 1>&2; return 1; fi
  done
}
check_db_exists(){
  if ! su -c "psql -d '${DB_NAME}' -c 'select 1;' > /dev/null 2>&1" ${CONTAINER_USER}; then
    printf "Database ${DB_NAME} does not exist\n"; return 1
  fi
}
save_schedule(){
  local schedules=()
  if [ -e ${CONFIG_PATH}/${SCHEDULE_TYPE} ]; then 
    schedules=($(cat ${CONFIG_PATH}/${SCHEDULE_TYPE}))
  else
    su -c "touch ${CONFIG_PATH}/${SCHEDULE_TYPE}" ${CONTAINER_USER}
  fi
  schedules[${#schedules[@]}]="${DB_NAME}"
  echo "${schedules[@]}" > ${CONFIG_PATH}/${SCHEDULE_TYPE}
}
####################
mkdirs
check_input
check_schedule_type
check_schedule_exists
check_db_exists
save_schedule
