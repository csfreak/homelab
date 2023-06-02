#!/bin/sh
set -e

if [ ! -e /config/nzbget.conf ]; then
    echo "Writing /config/nzbget.conf from ENV"
    env -0 | while IFS='=' read -r -d '' n v; do
        case $n in 
            "NZBGET_"*) 
            echo "${n#NZBGET_}=${v}" >> /config/nzbget.conf
            unset -v $n ;;
        esac
    done
fi

exec "$@"
