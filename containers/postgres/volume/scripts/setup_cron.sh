#!/usr/bin/env bash
####################
set -e
####################
readonly RUN_SCHEDULES='/app/scripts/run_dump_schedules.sh'
readonly DUMP_SCHEDULE_LOG='/tmp/dump_schedule.log'
####################
crate_logfile(){
  if ! [ -e ${DUMP_SCHEDULE_LOG} ]; then su -c "touch ${DUMP_SCHEDULE_LOG}" ${CONTAINER_USER}; fi
}
set_crontab(){
  if grep "${RUN_SCHEDULES}" /etc/crontab >/dev/null 2>&1; then return 0; fi
  cat << EOF >> /etc/crontab
0 */1 * * * root export CONTAINER_USER=${CONTAINER_USER}; cd /home/${CONTAINER_USER}; ${RUN_SCHEDULES} hourly
0 */12 * * * root export CONTAINER_USER=${CONTAINER_USER}; cd /home/${CONTAINER_USER}; ${RUN_SCHEDULES} daily_twice
0 0 * * * root export CONTAINER_USER=${CONTAINER_USER}; cd /home/${CONTAINER_USER}; ${RUN_SCHEDULES} daily
0 0 * * 0 root export CONTAINER_USER=${CONTAINER_USER}; cd /home/${CONTAINER_USER}; ${RUN_SCHEDULES} weekly
0 0 1 * * root export CONTAINER_USER=${CONTAINER_USER}; cd /home/${CONTAINER_USER}; ${RUN_SCHEDULES} monthly

EOF
}
####################
crate_logfile
set_crontab
