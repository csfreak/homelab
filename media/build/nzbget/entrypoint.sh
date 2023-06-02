#!/bin/sh
set -e

if [ ! -e /config/nzbget.conf ]; then
    echo "Writing /config/nzbget.conf from ENV"
    env -0 | while IFS='=' read -r -d '' n v; do
        case $n in 
            "NZBGET_CONFIG_"*) 
            echo "${n#NZBGET_CONFIG_}=${v}" >> /config/nzbget.conf ;;
        esac
    done
fi

exec "$@"
