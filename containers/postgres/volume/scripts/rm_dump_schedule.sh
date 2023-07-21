#!/usr/bin/env bash
####################
set -e
####################
readonly DB_NAME="${1}"
readonly SCHEDULE_TYPE="${2}"
readonly DUMP_PATH='/app/data/dump'
readonly CONFIG_PATH='/app/data/config/dump/schedule'
####################
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
  if ! [ -e ${CONFIG_PATH}/${SCHEDULE_TYPE} ]; then printf "No ${SCHEDULE_TYPE} schedule config\n" 1>&2; return 1; fi
  local schedules=($(cat ${CONFIG_PATH}/${SCHEDULE_TYPE}))
  if [ -z "${schedules}" ]; then printf "Empty ${SCHEDULE_TYPE} schedule config\n" 1>&2; return 1; fi
  for i in "${schedules[@]}"; do if [ "${i}" == "${DB_NAME}" ]; then return 0; fi; done
  printf "${DB_NAME} not present in ${SCHEDULE_TYPE} schedule\n" 1>&2; return 1
}
remove_schedule(){
  local schedules=($(cat ${CONFIG_PATH}/${SCHEDULE_TYPE}))
  for i in "${schedules[@]}"; do
    if [ "${i}" == "${DB_NAME}" ]; then 
      schedules=(${schedules[@]/${DB_NAME}})
      break
    fi
  done
  echo "${schedules[@]}" > ${CONFIG_PATH}/${SCHEDULE_TYPE}
}
####################
check_input
check_schedule_type
check_schedule_exists
remove_schedule
