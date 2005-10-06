shutdown_disabled() {
	ewarn "  Disabled shutdown!"
}

setup_shutdown() {
	source /etc/conf.d/vdr.shutdown
	[[ "${SHUTDOWN_ACTIVE:-no}" == "no" ]] && return

	if [[ -n "${USER_SHUTDOWN_SCRIPT}" ]]; then
		add_param "--shutdown=${USER_SHUTDOWN_SCRIPT}"
		return
	fi


	# no custum shutdown-script
	if ! grep -q /usr/lib/vdr/bin/vdrshutdown-really.sh /etc/sudoers; then
		ewarn "  missing entry in /etc/sudoers"
		einfo
		einfo "  please add this line to your /etc/sudoers file"
		einfo "  vdr ALL=NOPASSWD:/usr/lib/vdr/bin/vdrshutdown-really.sh"
		shutdown_disabled
		return
	fi

	if [[ -f /usr/lib/vdr/shutdown/shutdown-wakeup-${WAKEUP_METHOD}.sh ]]; then
		# test if need programs are there
		SHUTDOWN_EXITCODE=0
		source /usr/lib/vdr/shutdown/shutdown-wakeup-${WAKEUP_METHOD}.sh
		if [[ "${SHUTDOWN_EXITCODE}" != "0" ]]; then
			shutdown_disabled
			return
		fi
	else
		ewarn "  Wakeup-Method ${WAKEUP_METHOD} not supported!"
		shutdown_disabled
		return
	fi

	add_param "--shutdown=/usr/lib/vdr/bin/vdrshutdown-gate.sh"
}

setup_shutdown
