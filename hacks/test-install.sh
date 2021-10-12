#!/bin/bash

debug() {
    printf "::debug::%s\n" "$@"
}

error_count=0
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

group "Systemd Integration"
if ! systemctl cat portmaster.service 2>/dev/null >&2 ; then
    error "portmaster.service not found"
fi
if ! systemd-analyze verify portmaster.service ; then
    error "systemd-analyze returned an error for portmaster.service"
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
