# $Id$

#
# Reload modules on a watchdogrestart
#

addon_main() {
	if [ "${WATCHDOG_RELOAD_DVB_MODULES:-no}" = "yes" ]; then
		dvb-reload-modules
	fi
	return 0
}

