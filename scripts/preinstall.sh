#!/bin/bash

log() {
    printf "\033[33;1mportmaster:\033[0m %s\n" "$@"
}

set -eu

log "pre-install:" "$@"

checkConflicts() {
    if [ -d /var/lib/portmaster/updates ]; then
        log "Detected previous installation of Portmaster at"
        log "/var/lib/portmaster"
        log "Please uninstall the portmaster package and try again!"
        log "You settings will be migrated automatically during re-installation."
        exit 1
    fi
}

checkConflicts

# Upgrade:
#   deb: upgrade version-old version-new
#   rpm: 2
