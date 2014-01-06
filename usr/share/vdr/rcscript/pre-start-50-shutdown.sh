# $Id$

addon_main() {
	include shutdown-functions
	yesno "${SHUTDOWN_ACTIVE}" || return 0

	if [ -n "${USER_SHUTDOWN_SCRIPT}" ]; then
		add_param "--shutdown=${USER_SHUTDOWN_SCRIPT}"
		return 0
	fi

	# no custum shutdown-script
	add_param "--shutdown=/usr/share/vdr/bin/vdrshutdown-gate.sh"

	# warning about depricated acpi wakeup kernel > 2.6.38
	if [ "${WAKEUP_METHOD}" = acpi ]; then
		ewarn "use of acpi wakeup method is depricated"
		einfo "use rtc or nvram instead"
		logger -t vdr "WARNING:"
		logger -t vdr "use of acpi wakeup method is depricated"
		logger -t vdr "use rtc or nvram instead"
	fi

	return 0
}
