#!/usr/bin/env bash
####################
set -e
####################
source .env
####################
readonly HELP_MSG='usage: < build | up | down | clean | mk-systemd | rm-systemd | loaddb | dumpdb | createdb | dropdb | add_dump_schedule | rm_dump_schedule | psql | help >'
readonly RELDIR="$(dirname ${0})"
readonly ADMINER_IMG_NAME="docker.io/library/adminer:4.8.1-standalone"
####################
eprintln(){
	! [ -z "${1}" ] || eprintln 'eprintln err: undefined message'
	printf "${1}\n" 1>&2
	return 1
}
check_env(){
	! [ -z "${PG_IMG_NAME}" ] || eprintln 'missing env PG_IMG_NAME'
	! [ -z "${PG_CT_NAME}" ] || eprintln 'missing env PG_CT_NAME'
	! [ -z "${PG_PORT}" ] || eprintln 'missing env PG_PORT'
	! [ -z "${POSTGRES_PASSWORD}" ] || eprintln 'missing env POSTGRES_PASSWORD'
	! [ -z "${ADMINER_CT_NAME}" ] || eprintln 'missing env ADMINER_CT_NAME'
	! [ -z "${ADMINER_PORT}" ] || eprintln 'missing env ADMINER_PORT'
}
mkdirs(){
	mkdir -p "${RELDIR}"/data/postgres
	mkdir -p "${RELDIR}"/data
}
set_scripts_permissions(){
	chmod +x "${RELDIR}"/scripts/*.sh 1>/dev/null 2>&1 || true
	chmod +x "${RELDIR}"/scripts/postgres/*.sh 1>/dev/null 2>&1 || true
}
common(){
	check_env
	mkdirs
	set_scripts_permissions
}
build(){
	podman build \
		-f "${RELDIR}"/Dockerfile-postgres \
		--tag "${PG_IMG_NAME}" \
		"${RELDIR}"
	podman pull ${ADMINER_IMG_NAME}
}
mk_systemd() {
	! [ -e "/etc/systemd/system/${PG_CT_NAME}.service" ] \
	|| eprintln "service ${PG_CT_NAME} already exists"
	local user="${USER}"
	sudo bash -c "cat << EOF > /etc/systemd/system/${PG_CT_NAME}.service
[Unit]
Description=Postgres Pod
After=network.target

[Service]
Environment=\"PATH=/usr/local/bin:/usr/bin:/bin:${PATH}\"
User=${user}
Type=forking
ExecStart=/bin/bash -c \"cd ${PWD}/${RELDIR}; ./control.sh up\"
ExecStop=/bin/bash -c \"cd ${PWD}/${RELDIR}; ./control.sh down\"
Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF
"
	sudo systemctl enable "${PG_CT_NAME}".service
}
rm_systemd() {
	[ -e "/etc/systemd/system/${PG_CT_NAME}.service" ] || return 0
	sudo systemctl stop "${PG_CT_NAME}".service || true
	sudo systemctl disable "${PG_CT_NAME}".service
	sudo rm /etc/systemd/system/"${PG_CT_NAME}".service
}
up(){
	podman run --rm \
		-p="${PG_PORT}:5432" \
		-v="${RELDIR}/data:/data" \
		-v="${RELDIR}/data/postgres:/var/lib/postgresql/data" \
		--env 'CONTAINER_USER=root' \
		--env 'POSTGRES_USER=root' \
		--env-file="${RELDIR}/.env" \
		--name="${PG_CT_NAME}" \
		"localhost/${PG_IMG_NAME}" &

	podman run --rm \
		-p="${ADMINER_PORT}:8080" \
		--name="${ADMINER_CT_NAME}" \
		"${ADMINER_IMG_NAME}" &
}
down(){
	scripts/container_stop.sh "${PG_CT_NAME}" || true
	podman stop ${PG_CT_NAME} 1>/dev/null 2>&1 || true
	podman stop ${ADMINER_CT_NAME} 1>/dev/null 2>&1 || true
}
clean(){
	printf "This will clean all data. Are you sure? (Y/n): "
	read input
	[ "${input}" == "Y" ] || eprintln 'ABORT!'
	rm -rf "${RELDIR}"/data
}
loaddb(){
  if [ -z "${1}" ] || [ -z "${2}" ]; then eprintln 'Expected: [database name] [dump_label]\n'; fi
  podman exec -it ${PG_CT_NAME} /static/scripts/postgres/loaddb.sh "${1}" "${2}"
}
dumpdb(){
  if [ -z "${1}" ] || [ -z "${2}" ]; then eprintln 'Expected: [database name] [dump_label]\n'; fi
  podman exec -it ${PG_CT_NAME} /static/scripts/postgres/dumpdb.sh "${1}" "${2}"
}
createdb(){
  if [ -z "${1}" ] ; then eprintln 'Expected: [database name]\n'; fi
  podman exec -it ${PG_CT_NAME} /static/scripts/postgres/createdb.sh "${1}" 
}
dropdb(){
  if [ -z "${1}" ] ; then eprintln 'Expected: [database name]\n'; fi
  podman exec -it ${PG_CT_NAME} /static/scripts/postgres/dropdb.sh "${1}"
}
add_dump_schedule(){
  if [ -z "${1}" ] || [ -z "${2}" ]; then eprintln 'Expected: [database name] [schedule type]\n'; fi
  podman exec -it ${PG_CT_NAME} /static/scripts/postgres/add_dump_schedule.sh "${1}" "${2}"
}
rm_dump_schedule(){
  if [ -z "${1}" ] || [ -z "${2}" ]; then eprintln 'Expected: [database name] [schedule type]\n'; fi
  podman exec -it ${PG_CT_NAME} /static/scripts/postgres/rm_dump_schedule.sh "${1}" "${2}"
}
psql(){
  if [ -z "${1}" ] || [ -z "${2}" ]; then eprintln 'Expected: [database name] [psql command]\n'; fi
  podman exec ${PG_CT_NAME} psql -d "${1}"  -c "${2}"
}
####################
common
case ${1} in
	build) build ;;
	up) up ;;
	down) down ;;
	clean) clean ;;
	mk-systemd) mk_systemd ;;
	rm-systemd) rm_systemd ;;

  loaddb) loaddb "${2}" "${3}" ;;
  dumpdb) dumpdb "${2}" "${3}" ;;
  createdb) createdb "${2}" ;;
  dropdb) dropdb "${2}" ;;
  add_dump_schedule) add_dump_schedule "${2}" "${3}" ;;
  rm_dump_schedule) rm_dump_schedule "${2}" "${3}" ;;
  psql) psql "${2}" "${3}" ;;

	*) eprintln "${HELP_MSG}" ;;
esac


