#!/bin/bash

export HOME="/usr/lib/plexmediaserver"
export PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="/config/"
export PLEX_MEDIA_SERVER_HOME="/usr/lib/plexmediaserver"
export PLEX_MEDIA_SERVER_INFO_VENDOR="Red Hat Enterprise Linux"
export PLEX_MEDIA_SERVER_INFO_DEVICE="Openshift Container Platform 4"
export PLEX_MEDIA_SERVER_INFO_MODEL="Container"
export PLEX_MEDIA_SERVER_INFO_PLATFORM_VERSION="ubi8"

if [ ! -d "${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR}" ] ; then
  mkdir -p "${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR}"
fi

exec $@