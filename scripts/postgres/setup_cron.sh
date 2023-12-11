#!/usr/bin/env bash
####################
set -e
####################
readonly RUN_SCHEDULES='/static/scripts/postgres/run_dump_schedules.sh'
readonly DUMP_SCHEDULE_LOG='/data/dump_schedule.log'
####################
crate_logfile(){
  if ! [ -e ${DUMP_SCHEDULE_LOG} ]; then touch ${DUMP_SCHEDULE_LOG}; fi
}
set_crontab(){
  if grep "${RUN_SCHEDULES}" /etc/crontab >/dev/null 2>&1; then return 0; fi
  cat << EOF >> /etc/crontab
0 */1 * * *		root cd /root; ${RUN_SCHEDULES} hourly
0 */12 * * *	root cd /root; ${RUN_SCHEDULES} daily_twice
0 0 * * *			root cd /root; ${RUN_SCHEDULES} daily
0 0 * * 0			root cd /root; ${RUN_SCHEDULES} weekly
0 0 1 * *			root cd /root; ${RUN_SCHEDULES} monthly

EOF
}
####################
crate_logfile
set_crontab
