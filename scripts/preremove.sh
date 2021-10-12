#!/bin/sh

log() {
    printf "\033[33;1mportmaster:\033[0m %s\n" "$@"
}

set -eu

log "Pre-Remove: $@"

use_systemctl="True"
systemd_version=0
if ! command -V systemctl >/dev/null 2>&1; then
  use_systemctl="False"
else
    systemd_version=$(systemctl --version | head -1 | sed 's/systemd //g')
fi

preremove() {
    if [ $use_systemctl = "True" ]; then
        if (systemctl -q is-active portmaster.service); then
            log "Stopping portmaster.service"
            systemctl stop portmaster.service ||:
        fi
        if (systemctl -q is-enabled portmaster.service); then
            log "Disabling portmaster.service to launch at boot"
            systemctl disable portmaster.service
        fi
    fi
}

preremove