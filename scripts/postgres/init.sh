#!/usr/bin/env bash
####################
set -e
####################
readonly DUMP_SCHEDULE_LOG='/data/dump_schedule.log'
####################
set_pgdata_ownership(){
	chown -R ${USER}:${USER} /var/lib/postgresql/data
}
start_postgres(){
	docker-entrypoint.sh postgres & 
	echo $! > /data/postgres.pid
}
setup_backup_job(){
	/static/scripts/postgres/setup_cron.sh
	cron
	tail -f ${DUMP_SCHEDULE_LOG} &
}
keepalive_loop(){
	while kill -0 $(cat /data/postgres.pid) >/dev/null 2>&1; do sleep 1; done
	printf 'Processes are dead. Shutdown.\n'
}
run(){
	set_pgdata_ownership
	start_postgres
	setup_backup_job
	keepalive_loop
	# End
	set_pgdata_ownership
}
####################
run
