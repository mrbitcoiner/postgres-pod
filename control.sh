#!/usr/bin/env bash
####################
set -e
####################
readonly NETWORK="postgres"
readonly CONTAINERS=("postgres" "haproxy")
####################
create_directories(){
  for i in "${CONTAINERS[@]}"; do 
    mkdir -p containers/${i}/volume/scripts
    mkdir -p containers/${i}/volume/data
  done
}
set_scripts_permissions(){
  for i in "${CONTAINERS[@]}"; do
    if [ -e ./containers/${i}/volume/scripts/init.sh ]; then
      chmod +x ./containers/${i}/volume/scripts/*.sh
    fi
  done
}
copy_env(){
  if ! [ -e .env ]; then
    cp .env.example .env
  fi
}
set_env(){
  if [ -z "${1}" ] || [ -z "${2}" ]; then printf 'Expected: [ key ] [ value ]\n'; return 1; fi
  local key="${1}"
  local value="${2}"
  if ! grep "${key}=" .env > /dev/null; then
      echo "${key}=${value}" >> .env 
  else
      sed -i'.old' -e 's/'${key}'=.*/'${key}'='${value}'/g' .env 
  fi
}
set_uid_gid(){
  set_env "HOST_UID" "$(id -u)"
  set_env "HOST_GID" "$(id -g)"
}
create_docker_network(){
  if ! docker network ls | grep "${NETWORK}" > /dev/null; then
    docker network create -d bridge "${NETWORK}"
  fi
}
build_images(){
  docker-compose build \
    --build-arg "$(grep '^CONTAINER_USER=.*$' .env)" \
    --build-arg "$(grep '^POSTGRES_PASSWORD=.*$' .env)" \
    --build-arg "$(grep '^HOST_UID=.*$' .env)" \
    --build-arg "$(grep '^HOST_GID=.*$' .env)"
}
start_containers(){
  docker-compose up \
    --remove-orphans &
}
####################
setup(){
  copy_env
  set_uid_gid
  set_scripts_permissions
  create_docker_network
  build_images
  start_containers
}
teardown(){
  docker-compose down
}
clean(){
  printf "Are you sure? (Y/any): "
  read input
  if ! echo ${input} | grep '^Y$' > /dev/null; then
    printf 'Aborted\n'; return 1
  fi
  for i in "${CONTAINERS[@]}"; do
    local data_path="./containers/${i}/volume/data"
    if [ -e "${data_path}" ]; then
      rm -rfv ${data_path}
      printf "Data cleaned successfully!\n"
    fi
  done
}
####################
case ${1} in
  up) setup ;;
  down) teardown ;;
  clean) clean ;;
  *) printf 'Expected: [ up | down | clean | help ]\n'; exit 1 ;;
esac
