FROM postgres:15.3-bookworm

ARG DEBIAN_FRONTEND=noninteractive
ARG LANG=C
ARG CONTAINER_USER
ARG CONTAINER_UID
ARG CONTAINER_GID

ENV LANG=${LANG}
ENV CONTAINER_USER=${CONTAINER_USER}
ENV CONTAINER_UID=${CONTAINER_UID}
ENV CONTAINER_GID=${CONTAINER_GID}
ENV POSTGRES_USER=${CONTAINER_USER}

RUN apt update \
  && apt upgrade -y \
  && apt install --no-install-recommends -y cron

COPY ./volume/scripts /scripts

RUN /scripts/user_setup.sh ${CONTAINER_USER} ${CONTAINER_UID} ${CONTAINER_GID}

ENTRYPOINT ["/scripts/init.sh"]
