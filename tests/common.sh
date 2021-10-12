#!/bin/bash

#
# Utility methods for writing debug, warning and error messages
# for github-actions.
#
error_count=0
debug() {
    printf "::debug::%s\n" "$@"
}
info() {
    printf "::notice::%s\n" "$@"
}
error() {
    ((error_count++))
    printf "::error::%s\n" "$@"
}
warn() {
    printf "::warning::%s\n" "$@"
}
group() {
    printf "::group::%s\n" "$1"
}
endgroup() {
    printf "::endgroup::\n"
}

#
# Source /etc/os-release and gather some facts
# for os/distribution specific tests
#
. /etc/os-release

systemd_running="False"

if [ "$(pgrep systemd | head -n1)" = "1" ]; then
    debug "Found systemd running at $(pgrep systemd | head -1)"
    systemd_running="True"
fi

export systemd_running