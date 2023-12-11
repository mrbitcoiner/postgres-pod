#!/usr/bin/env bash
####################
set -e
####################
readonly SCHEDULE_TYPE="${1}"
readonly DUMP_PATH='/data/dump'
readonly CONFIG_PATH='/data/config/dump/schedule'
readonly PIDFILE_PATH='/data/config/dump/dump.pid'
####################
check_no_schedule_running(){
  if [ -e ${PIDFILE_PATH} ] && kill -0 $(cat ${PIDFILE_PATH}) > /dev/null 2>&1; then
    printf 'Another dump currently running\n' 1>&2; return 1
  fi
}
set_pidfile(){
  if ! printf $$ > ${PIDFILE_PATH}; then
    printf 'Error creating pidfile. Did you already setted up some schedule entry?\n' 1>&2; return 1
  fi
}
check_input(){
  if [ -z "${SCHEDULE_TYPE}" ]; then printf 'Expected: [database] [schedule type]\n' 1>&2; return 1; fi
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
}
run_schedule(){
  local schedules=($(cat ${CONFIG_PATH}/${SCHEDULE_TYPE}))
  for database in "${schedules[@]}"; do
    /static/scripts/postgres/dumpdb.sh "${database}" "${database}_${SCHEDULE_TYPE}.sql" 2>&1 \
		| xargs -I %s printf "[$(date +%F_%H-%M-%S)] | %s\n" \
		| tee -a /data/dump_schedule.log
  done
}
remove_pidfile(){
  rm ${PIDFILE_PATH}
}
####################
check_no_schedule_running
set_pidfile
check_input
check_schedule_type
check_schedule_exists
run_schedule
remove_pidfile
