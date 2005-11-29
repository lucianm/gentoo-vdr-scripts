addon_main() {
	[[ -z "${WATCHDOG_RESTART}" ]] && start_watchdog
}

