FROM debian:bullseye-slim

ARG HOST_UID
ARG HOST_GID
ARG CONTAINER_USER

ENV CONTAINER_USER=${CONTAINER_USER}

COPY ./volume/scripts /scripts

RUN /scripts/user_setup.sh "${CONTAINER_USER}" "${HOST_UID}" "${HOST_GID}"

RUN apt update

RUN apt install -y \
  haproxy openssl

ENTRYPOINT ["/scripts/init.sh"]
