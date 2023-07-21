#!/usr/bin/env bash
####################
set -e
####################
if [ -e .env ]; then
  source .env
fi
####################
check_env(){
  if ! [ -e .env ]; then printf 'You must copy .env.example to .env\n' 1>&2; return 1; fi
  if [ -z "${POSTGRES_CONTAINER_NAME}" ]; then printf 'Undefined env POSTGRES_CONTAINER_NAME\n' 1>&2; return 1; fi
  if [ -z "${ADMINER_CONTAINER_NAME}" ]; then printf 'Undefined env ADMINER_CONTAINER_NAME\n' 1>&2; return 1; fi
  if [ -z "${EXTERNAL_NETWORK}" ]; then printf 'Undefined env EXTERNAL_NETWORK\n' 1>&2; return 1; fi
  if [ -z "${POSTGRES_PASSWORD}" ]; then printf 'Undefined env POSTGRES_PASSWORD\n' 1>&2; return 1; fi
  if [ -z "${POSTGRES_EXT_PORT}" ]; then printf 'Undefined env POSTGRES_EXT_PORT\n' 1>&2; return 1; fi
  if [ -z "${ADMINER_EXT_PORT}" ]; then printf 'Undefined env ADMINER_EXT_PORT\n' 1>&2; return 1; fi
}
create_directories(){
  mkdir -p containers/postgres/volume/scripts
  mkdir -p containers/postgres/volume/data
}
set_scripts_permissions(){
  if [ -e ./containers/postgres/volume/scripts/init.sh ]; then
    chmod +x ./containers/postgres/volume/scripts/*.sh
  fi
  if [ -e ./scripts/container_stop.sh ]; then
    chmod +x ./scripts/*.sh
  fi
}
create_docker_network(){
  if ! docker network ls | awk '{print $2}' | grep "^${EXTERNAL_NETWORK}$" > /dev/null; then
    docker network create -d bridge "${EXTERNAL_NETWORK}"
  fi
}
create_docker_compose(){
  cat << EOF > docker-compose.yml
services:
  postgres:
    container_name: ${POSTGRES_CONTAINER_NAME}
    build: containers/postgres
    volumes:
      - ./containers/postgres/volume:/app
      - ./containers/postgres/volume/data/postgres:/var/lib/postgresql/data
    environment:
     - POSTGRES_USER=${USER}
     - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    networks:
      - postgres
    ports:
      - ${POSTGRES_EXT_PORT}:5432

  adminer:
    container_name: ${ADMINER_CONTAINER_NAME} 
    image: adminer:4.8.1-standalone
    networks:
      - postgres 
    ports:
      - ${ADMINER_EXT_PORT}:8080

networks:
  postgres:
    name: ${EXTERNAL_NETWORK} 
    external: true
EOF
}
####################
build_up_common(){
  check_env
  set_scripts_permissions
  create_docker_network
  create_docker_compose
}
build(){
  build_up_common
  docker-compose build \
    --build-arg CONTAINER_USER=${USER} \
    --build-arg CONTAINER_UID=$(id -u) \
    --build-arg CONTAINER_GID=$(id -g) 
}
up(){
  build_up_common
  docker-compose up --remove-orphans &
}
teardown(){
  ./scripts/container_stop.sh "${POSTGRES_CONTAINER_NAME}"
  docker-compose down
}
clean(){
  printf 'Are you sure? (Y/n): '
  read input
  if [ "${input}" != "Y" ]; then printf 'Abort!\n' 1>&2; return 1; fi
  rm -rfv ./containers/postgres/volume/data
}
loaddb(){
  if [ -z "${1}" ] || [ -z "${2}" ]; then printf 'Expected: [database name] [dump_label]\n' 1>&2; return 1; fi
  docker exec -it ${POSTGRES_CONTAINER_NAME} /app/scripts/loaddb.sh "${1}" "${2}"
}
dumpdb(){
  if [ -z "${1}" ] || [ -z "${2}" ]; then printf 'Expected: [database name] [dump_label]\n' 1>&2; return 1; fi
  docker exec -it ${POSTGRES_CONTAINER_NAME} /app/scripts/dumpdb.sh "${1}" "${2}"
}
createdb(){
  if [ -z "${1}" ] ; then printf 'Expected: [database name]\n' 1>&2; return 1; fi
  docker exec -it ${POSTGRES_CONTAINER_NAME} /app/scripts/createdb.sh "${1}" 
}
dropdb(){
  if [ -z "${1}" ] ; then printf 'Expected: [database name]\n' 1>&2; return 1; fi
  docker exec -it ${POSTGRES_CONTAINER_NAME} /app/scripts/dropdb.sh "${1}"
}
add_dump_schedule(){
  if [ -z "${1}" ] || [ -z "${2}" ]; then printf 'Expected: [database name] [schedule type]\n' 1>&2; return 1; fi
  docker exec -it ${POSTGRES_CONTAINER_NAME} /app/scripts/add_dump_schedule.sh "${1}" "${2}"
}
rm_dump_schedule(){
  if [ -z "${1}" ] || [ -z "${2}" ]; then printf 'Expected: [database name] [schedule type]\n' 1>&2; return 1; fi
  docker exec -it ${POSTGRES_CONTAINER_NAME} /app/scripts/rm_dump_schedule.sh "${1}" "${2}"
}
psql(){
  if [ -z "${1}" ] || [ -z "${2}" ]; then printf 'Expected: [database name] [psql command]\n' 1>&2; return 1; fi
  docker exec -it ${POSTGRES_CONTAINER_NAME} su -c "psql -d \"${1}\" -c \"${2}\"" ${USER}
}
####################
case ${1} in
  build) build ;;
  up) up ;;
  loaddb) loaddb "${2}" "${3}" ;;
  dumpdb) dumpdb "${2}" "${3}" ;;
  createdb) createdb "${2}" ;;
  dropdb) dropdb "${2}" ;;
  add_dump_schedule) add_dump_schedule "${2}" "${3}" ;;
  rm_dump_schedule) rm_dump_schedule "${2}" "${3}" ;;
  psql) psql "${2}" "${3}" ;;
  down) teardown ;;
  clean) clean ;;
  *) printf 'Usage: [ build | up | down | loaddb | dumpdb | createdb | dropdb | add_dump_schedule | rm_dump_schedule | psql | clean | help ]\n'; exit 1 ;;
esac
