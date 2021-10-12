#!/bin/sh

log() {
    printf "\033[33;1mportmaster:\033[0m $@\n"
}

set -eu

log "Pre-Install: $@"

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

case "$1" 