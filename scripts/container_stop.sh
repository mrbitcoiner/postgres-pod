#!/usr/bin/env bash
####################
set -e
####################
readonly CONTAINER_NAME="${1}"
readonly TIMEOUT_SECS='60'
####################
check_vars(){
  if [ -z "${CONTAINER_NAME}" ]; then printf 'Expected: CONTAINER_NAME\n' 1>&2; return 1; fi
}
order_shutdown(){
  podman exec ${CONTAINER_NAME} /static/scripts/postgres/shutdown.sh || true
}
container_running(){
  if podman ps -f name="${CONTAINER_NAME}" | grep "^.* ${CONTAINER_NAME}$" 2>&1>/dev/null; then
    return 0
  else
    return 1
  fi
}
loop_while_running_and_timeout_not_reached(){
  printf '\n'
  local count=0
  while [ "${count}" -le "${TIMEOUT_SECS}" ] && container_running; do
    printf '\r'
    printf "\rWaiting ${CONTAINER_NAME} shutdown ${count}/${TIMEOUT_SECS}s"
    sleep 1
    count="$(( ${count} + 1 ))"
  done
  printf '\n'
}
####################
check_vars
order_shutdown
loop_while_running_and_timeout_not_reached

