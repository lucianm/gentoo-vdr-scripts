
addon_main() {
	include shutdown-functions
	yesno "${SHUTDOWN_ACTIVE}" || return 0

	return 0
}
