#!/bin/sh

log() {
  printf "\033[33;1mportmaster:\033[0m %s\n" "$@"
}

set -e

log "post-remove:" "$@"

cleanup() {
    rm -rf /opt/portmaster/updates
    rm -rf /opt/portmaster
    rm /lib/systemd/system/portmaster.service ||:
}

uninstall() {
  cleanup
}

upgrade() {
  # we don't do anything on upgrade yet ...
  true ;
}

action="$1"
if  [ "$1" = "configure" ] && [ -z "$2" ]; then
  # Alpine linux does not pass args, and deb passes $1=configure
  action="install"
elif [ "$1" = "configure" ] && [ -n "$2" ]; then
    # deb passes $1=configure $2=<current version>
    action="upgrade"
fi

case "$action" in
  "1" | "install")
    log "post remove of clean install"
    uninstall
    ;;
  "2" | "upgrade")
    log "post remove of upgrade"
    upgrade
    ;;
  *)
    # $1 == version being installed  
    log "post remove of alpine"
    log "Alpine linux is not yet supported"
    exit 1
    ;;
esac