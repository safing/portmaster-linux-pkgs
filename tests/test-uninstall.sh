#!/bin/bash

. ./common.sh

group "Ensure portmaster is not running"
    if is_systemd_running; then
        if systemctl is-active portmaster.service ; then
            error "portmaster.service should have been stopped on uninstall"
        fi
    else
        info "Skipping systemd service check ..."
    fi
endgroup

#
# A normal uninstallation should keep user data
# and logs in-place
#
group "Settings and logs are kept"
if ! [ -d /opt/portmaster/databases ] ; then
    error "Portmaster databases should have been left in tree"
else
    info "Portmaster databases are left in tree as expected"
fi

if ! [ -e /opt/portmaster/config.json ]; then
    error "Portmaster global settings should have been left in tree"
else
    info "Portmaster global settings are left in tree as expected"
fi

if ! [ -d /opt/portmaster/logs ] ; then
    error "Portmaster logs should have been left in tree"
else
    info "Portmaster logs are left in tree as expected"
fi
endgroup

