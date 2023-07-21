#!/usr/bin/env bash
####################
set -e
####################
readonly DUMP_SCHEDULE_LOG='/tmp/dump_schedule.log'
####################
chown -R ${CONTAINER_USER}:${CONTAINER_USER} /app /var/lib/postgresql/data /var/run/postgresql

if [ -e /app/scripts/custom/init.sh ]; then
  /app/scripts/custom/init.sh
fi

su -c 'docker-entrypoint.sh postgres' ${CONTAINER_USER} &
su -c "echo $! > /app/data/postgres.pid" ${CONTAINER_USER}

/app/scripts/setup_cron.sh
cron
tail -f ${DUMP_SCHEDULE_LOG} &

while kill -0 $(cat /app/data/postgres.pid) >/dev/null 2>&1; do sleep 1; done
printf 'Processes are dead. Shutdown.\n'
