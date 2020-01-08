
#
# Reload modules on a watchdogrestart
#

addon_main() {
	if yesno "${WATCHDOG_RELOAD_DVB_MODULES}"; then
		dvb-reload-modules reload
	fi
	return 0
}
