
addon_main() {
	include shutdown-functions
	yesno "${SHUTDOWN_ACTIVE}" || return 0

	if [ -n "${USER_SHUTDOWN_SCRIPT}" ]; then
		add_param "--shutdown=${USER_SHUTDOWN_SCRIPT}"
		return 0
	fi

	# no custum shutdown-script
	add_param "--shutdown=/usr/share/vdr/bin/vdrshutdown-gate.sh"

	return 0
}
