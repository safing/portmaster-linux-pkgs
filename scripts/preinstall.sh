#!/bin/sh

set -e

echo "\033[33;1mportmaster:\033[0m Pre-Install: $@"

checkConflicts() {
    if [ -d /var/lib/portmaster/updates ]; then
        echo "\033[31;1mportmaster: Detected previous installation of Portmaster at\033[0m"
        echo "\033[31;1mportmaster: /var/lib/portmaster\033[0m"
        echo "\033[31;1mportmaster: Please uninstall the portmaster package and try again!\033[0m"
        echo "\033[31;1mportmaster: You settings will be migrated automatically\033[0m"
        exit 1
    fi
}

checkConflicts
