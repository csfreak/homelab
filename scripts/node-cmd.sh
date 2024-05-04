#!/bin/zsh

# SYNTAX:
#   catch stderr stdout statuscode COMMAND [ARG1[ ARG2[ ...[ ARGN]]]]
catch() {
    {
        IFS=$'\n' read -r -d '' "$1";
        IFS=$'\n' read -r -d '' "$2";
        IFS=$'\n' read -r -d '' "$3";
    } < <((printf '\0%s\0%d\0' "$(shift 3; ${@})" "${?}" 1>&2) 2>&1)
}

OC="/opt/homebrew/bin/oc"
nodes=("${(@f)$(${OC} get nodes --no-headers --output custom-columns=NAME:.metadata.name)}")

for node in ${nodes}
do 
    fqdn="${node}.homelab.csfreak.com"
    cmd=${@} 
    [ -z $cmd ] && cmd=("uptime")
    ssh_cmd=("ssh" "-l" "core" ${fqdn})
    catch_vars=(STDERR STDOUT CODE)
    catch ${catch_vars[@]} ${ssh_cmd[@]} ${cmd[@]}
    
    echo -n ${fqdn}:
    [[ ${CODE} -eq 0 ]] && echo ' \e[1;32mOK\e[0m' || echo ' \e[1;31mERR\e[0m'
    if [ -n "${STDOUT}" ]; then
        echo ${STDOUT} | awk  -F'\n' '{print "\t" $0}'
    fi
    if [ -n "${STDERR}" ]; then
        echo "\e[1;31mSTDERR\e[0m: ${#STDERR}"
        echo ${STDERR} | awk  -F'\n' '{print "\t" $0}'
    fi
done