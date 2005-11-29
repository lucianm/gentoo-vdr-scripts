addon_main() {
	[[ -z "${WATCHDOG_RESTART}" ]] && stop_watchdog
}

