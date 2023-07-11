#!/bin/bash

[ "${DEBUG}" == "yes" ] && set -x

function add_config_value() {
  local key=${1}
  local value=${2}
  # local config_file=${3:-/etc/postfix/main.cf}
  [ "${key}" == "" ] && echo "ERROR: No key set !!" && exit 1
  [ "${value}" == "" ] && echo "ERROR: No value set !!" && exit 1

  echo "Setting configuration option ${key} with value: ${value}"
 postconf ${CMD_ARGS} -e "${key} = ${value}"
}

# Read password and username from file to avoid unsecure env variables
if [ -n "${SMTP_PASSWORD_FILE}" ]; then [ -e "${SMTP_PASSWORD_FILE}" ] && SMTP_PASSWORD=$(cat "${SMTP_PASSWORD_FILE}") || echo "SMTP_PASSWORD_FILE defined, but file not existing, skipping."; fi
if [ -n "${SMTP_USERNAME_FILE}" ]; then [ -e "${SMTP_USERNAME_FILE}" ] && SMTP_USERNAME=$(cat "${SMTP_USERNAME_FILE}") || echo "SMTP_USERNAME_FILE defined, but file not existing, skipping."; fi
if [ -n "${SMTP_SERVER_FILE}" ]; then [ -e "${SMTP_SERVER_FILE}" ] && SMTP_SERVER=$(cat "${SMTP_SERVER_FILE}") || echo "SMTP_SERVER_FILE defined, but file not existing, skipping."; fi

[ -z "${SMTP_SERVER}" ] && echo "SMTP_SERVER is not set" && exit 1
[ -z "${SERVER_HOSTNAME}" ] && echo "SERVER_HOSTNAME is not set" && exit 1
[ ! -z "${SMTP_USERNAME}" -a -z "${SMTP_PASSWORD}" ] && echo "SMTP_USERNAME is set but SMTP_PASSWORD is not set" && exit 1

SMTP_PORT="${SMTP_PORT:-587}"

#Get the domain from the server host name
DOMAIN=`echo ${SERVER_HOSTNAME} | awk 'BEGIN{FS=OFS="."}{print $(NF-1),$NF}'`

if [ ! -z "${POSTFIX_CONFIG_DIR}" ]; then
    echo "Copying Configs to ${POSTFIX_CONFIG_DIR}"
    cp -Rnv /etc/postfix/* ${POSTFIX_CONFIG_DIR}
else
    POSTFIX_CONFIG_DIR="/etc/postfix"
fi

CMD_ARGS="${CMD_ARGS} -c ${POSTFIX_CONFIG_DIR}"

if [ ! -z ${LOGFILE} ] && [ "$(dirname ${LOGFILE})" != "/dev" ]; then
  mkdir -p $(dirname ${LOGFILE})
  touch ${LOGFILE}
fi

# Set needed config options
add_config_value "maillog_file" "${LOGFILE:-/dev/stdout}"
add_config_value "myhostname" ${SERVER_HOSTNAME}
add_config_value "mydomain" ${DOMAIN}
add_config_value "mydestination" "${DESTINATION:-localhost}"
add_config_value "myorigin" '$mydomain'
add_config_value "relayhost" "[${SMTP_SERVER}]:${SMTP_PORT}"
add_config_value "smtp_use_tls" "yes"
add_config_value "smtp_transport_rate_delay" "${SMTP_RATE_DELAY:-0s}"
if [ ! -z "${SMTP_USERNAME}" ]; then
  add_config_value "smtp_sasl_auth_enable" "yes"
  add_config_value "smtp_sasl_password_maps" "lmdb:${POSTFIX_CONFIG_DIR}/sasl_passwd"
  add_config_value "smtp_sasl_security_options" "noanonymous"
fi
add_config_value "always_add_missing_headers" "${ALWAYS_ADD_MISSING_HEADERS:-no}"
#Also use "native" option to allow looking up hosts added to /etc/hosts via
# docker options (issue #51)
add_config_value "smtp_host_lookup" "native,dns"

if [ "${SMTP_PORT}" = "465" ]; then
  add_config_value "smtp_tls_wrappermode" "yes"
  add_config_value "smtp_tls_security_level" "encrypt"
fi

# Bind to both IPv4 and IPv4
add_config_value "inet_protocols" "all"

# Create sasl_passwd file with auth credentials
if [ ! -f ${POSTFIX_CONFIG_DIR}/sasl_passwd -a ! -z "${SMTP_USERNAME}" ]; then
  grep -q "${SMTP_SERVER}" ${POSTFIX_CONFIG_DIR}/sasl_passwd  > /dev/null 2>&1
  if [ $? -gt 0 ]; then
    echo "Adding SASL authentication configuration"
    echo "[${SMTP_SERVER}]:${SMTP_PORT} ${SMTP_USERNAME}:${SMTP_PASSWORD}" >> ${POSTFIX_CONFIG_DIR}/sasl_passwd
    postmap ${CMD_ARGS} ${POSTFIX_CONFIG_DIR}/sasl_passwd
  fi
fi

#Set header tag
if [ ! -z "${SMTP_HEADER_TAG}" ]; then
  postconf ${CMD_ARGS} -e "header_checks = regexp:${POSTFIX_CONFIG_DIR}/header_checks"
  echo -e "/^MIME-Version:/i PREPEND RelayTag: $SMTP_HEADER_TAG\n/^Content-Transfer-Encoding:/i PREPEND RelayTag: $SMTP_HEADER_TAG" >> ${POSTFIX_CONFIG_DIR}/header_checks
  echo "Setting configuration option SMTP_HEADER_TAG with value: ${SMTP_HEADER_TAG}"
fi

add_config_value "mynetworks" "${SMTP_NETWORKS:-10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16}"

if [ ! -z "${SMTP_ALLOWED_SENDERS}" ]; then
    postconf ${CMD_ARGS} -e "smtpd_sender_restrictions = check_sender_access lmdb:${POSTFIX_CONFIG_DIR}/allowed_senders, reject"
    for i in $(sed 's/,/\ /g' <<<$SMTP_NETWORKS); do
        echo "${i} OK" >> ${POSTFIX_CONFIG_DIR}/allowed_senders
    done
    postmap ${CMD_ARGS} lmdb:${POSTFIX_CONFIG_DIR}/allowed_senders
fi
    

# Set SMTPUTF8
if [ ! -z "${SMTPUTF8_ENABLE}" ]; then
    add_config_value "smtputf8_enable" ${SMTPUTF8_ENABLE}
fi


# Set message_size_limit
if [ ! -z "${MESSAGE_SIZE_LIMIT}" ]; then
  add_config_value "message_size_limit" ${MESSAGE_SIZE_LIMIT}
fi

#Start services

# If host mounting /var/spool/postfix, we need to delete old pid file before
# starting services
rm -f /var/spool/postfix/pid/master.pid

exec /usr/sbin/postfix ${CMD_ARGS} start-fg