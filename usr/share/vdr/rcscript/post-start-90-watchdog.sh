# $Id$
addon_main() {
	[ -z "${WATCHDOG_RESTART}" ] && start_watchdog
	return 0
}

