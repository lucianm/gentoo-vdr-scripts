# $Id$

list_wakeup_methods() {
	local methods
	local m
	for m in ${shutdown_script_dir}/wakeup-*.sh; do
		m="${m##*wakeup-}"
		m="${m%.sh}"
		methods="${methods} ${m}"
	done
	einfo "    Available shutdown methods:${methods}"
	einfo "    There are some useflags to enable more shutdown methods."
	einfo "    You have to reemerge gentoo-vdr-scripts with the new use-flags set."
}

addon_main() {
	include shutdown-functions
	[ "${SHUTDOWN_ACTIVE}" = "no" ] && return 0

	if [ -n "${USER_SHUTDOWN_SCRIPT}" ]; then
		add_param "--shutdown=${USER_SHUTDOWN_SCRIPT}"
		return 0
	fi

	# no custum shutdown-script
	add_param "--shutdown=/usr/share/vdr/bin/vdrshutdown-gate.sh"

	# some sanity warnings
	if ! grep -q /usr/share/vdr/bin/vdrshutdown-really.sh /etc/sudoers; then
		ewarn "  missing entry in /etc/sudoers"
		ewarn
		ewarn "  please add this line to your /etc/sudoers file"
		ewarn "  vdr ALL=NOPASSWD:/usr/share/vdr/bin/vdrshutdown-really.sh"
		ewarn
		ewarn "  or call emerge --config gentoo-vdr-scripts"
		ewarn
	fi

	if [ ! -r "${shutdown_script_dir}/wakeup-${WAKEUP_METHOD}.sh" ]; then
		eerror "  Wakeup-Method ${WAKEUP_METHOD} not supported!"
		vdr_log "Wakeup-Method ${WAKEUP_METHOD} not supported!"
		list_wakeup_methods
	fi

	return 0
}

