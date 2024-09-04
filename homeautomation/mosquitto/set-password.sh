#! /bin/sh -
if [ -n "${DEBUG}" ]; then
    set -x
fi

PASSWD_FILE="/mosquitto/secret/mosquitto.passwd"
PASSWD_CMD="/usr/bin/mosquitto_passwd"

if [ ! -e ${PASSWD_FILE} ]; then
    # create passwd file
    touch ${PASSWD_FILE}
    # mosquitto complains if file permissions are not 0600
    chmod 600 ${PASSWD_FILE}
    # mosquitto complains if file group doesnt match users primary group
    chown :0 ${PASSWD_FILE}
fi

for ENVVAR in $(set | grep -o "^MOSQUITTO_USER_[A-Z0-9]\+" ); do
    USERNAME=$(echo "${ENVVAR#MOSQUITTO_USER_}" | tr "[:upper:]" "[:lower:]")
    eval "PASSWORD=\$${ENVVAR}"
    ${PASSWD_CMD} -b ${PASSWD_FILE} ${USERNAME} ${PASSWORD}
done