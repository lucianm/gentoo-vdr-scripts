
source /usr/lib/vdr/rcscript/functions-shutdown.sh

list_wakeup_methods() {
	local methods
	local m
	for m in ${shutdown_script_dir}/wakeup-*.sh; do
		m=${m//*\wakeup-//}
		methods="${methods} ${m}"
	done
	einfo "  Available shutdown methods: ${methods}"
	einfo "  There may be some more methods available when activated via use flag."
}

shutdown_disabled() {
	ewarn "  Disabled shutdown!"
}

setup_shutdown() {
	read_shutdown_config
	[[ "${SHUTDOWN_ACTIVE}" == "no" ]] && return

	if [[ -n "${USER_SHUTDOWN_SCRIPT}" ]]; then
		add_param "--shutdown=${USER_SHUTDOWN_SCRIPT}"
		return
	fi

	# no custum shutdown-script

	# test for good sudo-configuration
	if ! grep -q /usr/lib/vdr/bin/vdrshutdown-really.sh /etc/sudoers; then
		ewarn "  missing entry in /etc/sudoers"
		einfo
		einfo "  please add this line to your /etc/sudoers file"
		einfo "  vdr ALL=NOPASSWD:/usr/lib/vdr/bin/vdrshutdown-really.sh"
		shutdown_disabled
		return
	fi

	if [[ -f ${shutdown_script_dir}/wakeup-${WAKEUP_METHOD}.sh ]]; then
		# test if needed programs are there
		SHUTDOWN_EXITCODE=0
		source ${shutdown_script_dir}/wakeup-${WAKEUP_METHOD}.sh
		if [[ "${SHUTDOWN_EXITCODE}" != "0" ]]; then
			list_wakeup_methods
			shutdown_disabled
			return
		fi
	else
		ewarn "  Wakeup-Method ${WAKEUP_METHOD} not supported!"
		list_wakeup_methods
		shutdown_disabled
		return
	fi

	add_param "--shutdown=/usr/lib/vdr/bin/vdrshutdown-gate.sh"
}

setup_shutdown
