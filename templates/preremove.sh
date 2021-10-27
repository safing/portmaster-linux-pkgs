#!/bin/bash

{{ file.Read "common.sh" }}

log "pre-remove:" "$@"

use_systemctl="True"
if ! command -V systemctl >/dev/null 2>&1; then
  use_systemctl="False"
fi

preremove() {
    if [ $use_systemctl = "True" ]; then
        if (systemctl -q is-active portmaster.service); then
            log "Stopping portmaster.service"
            systemctl stop portmaster.service ||:
        fi
        if (systemctl -q is-enabled portmaster.service); then
            log "Disabling portmaster.service to launch at boot"
            systemctl disable portmaster.service ||:
        fi
    fi
}

upgrade() {
    true ; # There's nothing to do before an upgrade.
}

action="$1"
if  [ "$1" = "remove" ] && [ -z "$2" ]; then
  # Alpine linux does not pass args
  # deb passes $1=remove
  # rpm passes $1=0
  action="uninstall"
elif [ "$1" = "upgrade" ] && [ -n "$2" ]; then
    # deb passes $1=upgrade $2=version
    # rpm passes $1=1
    action="upgrade"
fi

case "$action" in
  "0" | "uninstall")
    log "pre remove of complete uninstall"
    preremove
    ;;
  "1" | "upgrade")
    log "pre remove of upgrade"
    upgrade
    ;;
  *)
    # $1 == version being installed  
    log "pre remove of alpine"
    log "Alpine linux is not yet supported"
    exit 1
    ;;
esac