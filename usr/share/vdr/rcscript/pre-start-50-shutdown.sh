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

	# some sanity warnings
	if ! grep -q /usr/share/vdr/bin/vdrshutdown-really.sh /etc/sudoers; then
		ewarn "  depricated entry in /etc/sudoers"
		ewarn
		ewarn "  To keep the shutdown work correctly, remove the line from /etc/sudoers"
		ewarn "  vdr ALL=NOPASSWD:/usr/share/vdr/bin/vdrshutdown-really.sh"
		ewarn
		ewarn "  or call emerge --config gentoo-vdr-scripts"
		ewarn
		logger -t vdr "ERROR: Depricated entry in /etc/sudoers, please migrate"
	fi
	return 0
}
