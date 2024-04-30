#!/bin/zsh
set -x

OC="/opt/homebrew/bin/oc"

${OC} adm reboot-machine-config-pool mcp/master mcp/worker
${OC} adm wait-for-node-reboot nodes --all
