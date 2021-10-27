#!/bin/bash

{{ file.Read "templates/snippets/common.sh" }}

log "pre-remove:" "$@"


preremove() {
    {{ file.Read "templates/snippets/pre-remove.sh" | strings.Indent 4 " " }}
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
      ;;
    *)
      # $1 == version being installed  
      log "pre remove of alpine"
      log "Alpine linux is not yet supported"
      exit 1
      ;;
esac