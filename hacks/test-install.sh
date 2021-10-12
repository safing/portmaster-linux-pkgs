#!/bin/bash

#
# Utility methods for writing debug, warning and error messages
# for github-actions.
#
error_count=0
debug() {
    printf "::debug::%s\n" "$@"
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
    systemd_running="True"
fi

#
# Perform our tests
#
group "Systemd Integration"
    #
    # the following tests only work if the system is booted using
    # systemd 
    #
    if [ "${systemd_running}" = "True" ]; then
        debug "Test if portmaster.service can be reached"
        if ! systemctl cat portmaster.service 2>/dev/null >&2 ; then
            error "portmaster.service not found"
        fi
    fi

    #
    # The following tests should work without the daemon running except
    # on Mint19 ...
    #
    if ! [ "${VERSION}" = "19 (Tara)" ] || [ "${systemd_running}" = "True" ] ; then # Skip systemd tests on Mint19 ...
        debug "Use systemd-analyze to verify portmaster.service"
        if ! systemd-analyze verify portmaster.service ; then
            error "systemd-analyze returned an error for portmaster.service"
        fi
    fi
endgroup

group "Desktop file"
    debug "Testing portmaster.desktop"
    if ! desktop-file-validate portmaster.desktop ; then
        error "portmaster.desktop seems invalid"
    fi

    debug "Testing portmaster_notifier.desktop"
    if ! desktop-file-validate portmaster_notifier.desktop ; then
        error "portmaster_notifier.desktop seems invalid"
    fi
endgroup

#
# Abort with a non-zero exit code if we found at least one
# error.
#
if [ "$error_count" -gt 0 ]; then
    echo "::error::${error_count} errors encountered"
    exit 1
fi
