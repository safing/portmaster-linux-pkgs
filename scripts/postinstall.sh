#!/bin/sh

set -e

echo "\033[33;1mportmaster:\033[0m Post-Install: $@"

#
# Prepare and gather some facts about the system we're installing on
#
use_systemctl="True"
systemd_version=0
if ! command -V systemctl >/dev/null 2>&1; then
  use_systemctl="False"
else
    systemd_version=$(systemctl --version | head -1 | sed 's/systemd //g')
fi
has_desktop_file_install="False"
if command -V desktop-file-install >/dev/null 2>&1; then
    has_desktop_file_install="True"
fi
download_agent=${PMSTART_UPDATE_AGENT:=Start}
skip_downloads=${PMSTART_SKIP_DOWNLOAD:=False}

. /etc/os-release

matches() {
    input="$1"
    pattern="$2"
    echo "$input" | grep -q "$pattern"
}

download_modules() {
    if [ "${skip_downloads}" = "True" ]; then
        echo "\033[33;1mportmaster:\033[0m Downloading of Portmaster modules skipped!"
        echo "\033[33;1mportmaster:\033[0m  Please run '/opt/portmaster/bin/portmaster-start --data /opt/portmaster update' manually.\n"
        return
    fi
    /opt/portmaster/bin/portmaster-start --data /opt/portmaster update --update-agent ${download_agent}
}

cleanInstall() {
    #
    # install .desktop files, either using desktop-file-install when available
    # or by just copying the files into /usr/share/applications.
    #
    if [ $has_desktop_file_install = "True" ]; then
        desktop-file-install /opt/portmaster/portmaster.desktop ||:
        desktop-file-install /opt/portmaster/portmaster_notifier.desktop ||:
    elif [ -d /usr/share/applications ]; then
        cp /opt/portmaster/portmaster.desktop /usr/share/applications 2>/dev/null ||:
        cp /opt/portmaster/portmaster_notifier.desktop /usr/share/applications 2>/dev/null ||:
    fi

    #
    # Add a symlink for the portmaster service unit in case we need it.
    #
    if [ $use_systemctl = "True" ]; then
        # not all distros have migrated /lib to /usr/lib yet but all that
        # have provide a symlink from /lib -> /usr/lib so we just prefix with
        # /lib here.
        ln -s /lib/systemd/system/portmaster.service /opt/portmaster/portmaster.service
    fi

    #
    # Finally, trigger downloading modules. As this requires internet access
    # it is more likely to fail and is thus the last thing we do.
    #
    download_modules
}

upgrade() {
    #
    # This is executed in the post-install of an upgrade operation.
    #

    #
    # If there's already a /var/lib/portmaster installation we're going to move
    # configs and databases and remove the complete directory
    # The preinstall.sh already checked that /var/lib/portmaster/updates MUST NOT
    # exist so we should be safe to touch the databases here.
    #
    if [ -d /var/lib/portmaster ]; then
        if [ ! -d /opt/portmaster/config.json ]; then
            echo "\033[33;1mportmaster:\033[0m Migrating from previous installation at /var/lib/portmaster to /opt/portmaster ..."
            mv /var/lib/portmaster/databases /opt/portmaster/databases ||:
            mv /var/lib/portmaster/config.json /opt/portmaster/config.json ||:
        fi
        echo "\033[33;1mportmaster:\033[0m Removing previous installation directory at /var/lib/portmaster"
        rm -r /var/lib/portmaster ||:
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
