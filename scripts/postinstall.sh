#!/bin/sh

log() {
    printf "\033[33;1mportmaster:\033[0m $@\n"
}

set -eu

log "Post-Install: $@"

#
# Prepare and gather some facts about the system we're installing on
#
use_systemctl="True"
systemd_version=0
if ! command -V systemctl >/dev/null 2>&1; then
  use_systemctl="False"
else
    systemd_version="$(systemctl --version | head -1 | sed 's/systemd //g')"
fi
has_desktop_file_install="False"
if command -V desktop-file-install >/dev/null 2>&1; then
    has_desktop_file_install="True"
fi
download_agent="${PMSTART_UPDATE_AGENT:=Start}"
skip_downloads="${PMSTART_SKIP_DOWNLOAD:=False}"

# TODO(ppacher): update selinux context for portmaster-start
use_selinux="True"
if ! command -V getenforce >/dev/null 2>&1; then
    use_selinux="False"
fi

. /etc/os-release

matches() {
    local input="$1"
    local pattern="$2"
    echo "$input" | grep -q "$pattern"
}

download_modules() {
    if [ "${skip_downloads}" = "True" ]; then
        log "Downloading of Portmaster modules skipped!"
        log "Please run '/opt/portmaster/portmaster-start --data /opt/portmaster update' manually.\n"
        return
    fi
    log "Downloading portmaster modules. This may take a while ..."
    /opt/portmaster/portmaster-start --data /opt/portmaster update --update-agent ${download_agent} 2>/dev/null >/dev/null || (
        log "Failed to download modules"
        log "Please run '/opt/portmaster/portmaster-start --data /opt/portmaster update' manually.\n"
    )
}

cleanInstall() {
    #
    # install .desktop files, either using desktop-file-install when available
    # or by just copying the files into /usr/share/applications.
    #
    if [ "${has_desktop_file_install}" = "True" ]; then
        desktop-file-install /opt/portmaster/portmaster.desktop ||:
        desktop-file-install /opt/portmaster/portmaster_notifier.desktop ||:
    elif [ -d /usr/share/applications ]; then
        cp /opt/portmaster/portmaster.desktop /usr/share/applications 2>/dev/null ||:
        cp /opt/portmaster/portmaster_notifier.desktop /usr/share/applications 2>/dev/null ||:
    fi

    #
    # Add a symlink for the portmaster service unit in case we need it.
    #
    if [ "${use_systemctl}" = "True" ]; then
        # not all distros have migrated /lib to /usr/lib yet but all that
        # have provide a symlink from /lib -> /usr/lib so we just prefix with
        # /lib here.
        ln -s /opt/portmaster/portmaster.service /lib/systemd/system/portmaster.service 

        # enable the portmaster service to launch at boot
        log "Configuring portmaster.service to launch at boot"
        systemctl enable portmaster.service
    fi

    #
    # Fix selinux permissions for portmaster-start
    #
    if [ "${use_selinux}" = "True" ]; then
        chcon -t bin_t /opt/portmaster/portmaster-start
    fi

    #
    # Finally, trigger downloading modules. As this requires internet access
    # it is more likely to fail and is thus the last thing we do.
    #
    download_modules
}

#
# This is executed in the post-install of an upgrade operation.
#
upgrade() {
    #
    # As of 0.4.0 portmaster-control has been renamed to portmaster-start
    # and is not placed in /usr/bin anymore. Unfortunately, the postrm script
    # of the old installer does not get rid of portmaster-control so we should
    # take care during an upgrade.
    #
    rm /usr/bin/portmaster-control 2>/dev/null >&2 ||:

    #
    # If there's already a /var/lib/portmaster installation we're going to move
    # configs and databases and remove the complete directory
    # The preinstall.sh already checked that /var/lib/portmaster/updates MUST NOT
    # exist so we should be safe to touch the databases here.
    #
    if [ -d /var/lib/portmaster ]; then
        if [ ! -d /opt/portmaster/config.json ]; then
            log "Migrating from previous installation at /var/lib/portmaster to /opt/portmaster ..."
            mv /var/lib/portmaster/databases /opt/portmaster/databases ||:
            mv /var/lib/portmaster/config.json /opt/portmaster/config.json ||:
        fi
        log "Removing previous installation directory at /var/lib/portmaster"
        rm -r /var/lib/portmaster 2>/dev/null >&2 ||:
    fi
}

# Step 2, check if this is a clean install or an upgrade
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
    cleanInstall
    ;;
  "2" | "upgrade")
    upgrade
    ;;
  *)
    # Alpine
    # $1 == version being installed  
    cleanInstall
    ;;
esac
