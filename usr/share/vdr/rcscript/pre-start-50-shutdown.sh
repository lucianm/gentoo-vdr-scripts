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
	if grep -q /usr/share/vdr/bin/vdrshutdown-really.sh /etc/sudoers; then
		eerror "  depricated entry in /etc/sudoers"
		eerror "  To keep the shutdown work correctly, remove the line from /etc/sudoers"
		eerror "  vdr ALL=NOPASSWD:/usr/share/vdr/bin/vdrshutdown-really.sh"
		eerror "  or call emerge --config gentoo-vdr-scripts"
		logger -t vdr "ERROR: Depricated entry in /etc/sudoers, please migrate"
	fi
	return 0
}
