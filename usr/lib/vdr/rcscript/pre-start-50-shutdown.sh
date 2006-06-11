# $Id$

list_wakeup_methods() {
	local methods
	local m
	for m in ${shutdown_script_dir}/wakeup-*.sh; do
		m=${m//*\/wakeup-/}
		methods="${methods} ${m/.sh/}"
	done
	vdr_einfo "    Available shutdown methods:${methods}"
	vdr_einfo "    There are some useflags to enable more shutdown methods."
	vdr_einfo "    You have to reemerge gentoo-vdr-scripts with the new use-flags set."
}

shutdown_disabled() {
	vdr_eerror "  Disabled shutdown!"
}

addon_main() {
	include shutdown-functions
	[[ "${SHUTDOWN_ACTIVE}" == "no" ]] && return 0

	if [[ -n "${USER_SHUTDOWN_SCRIPT}" ]]; then
		add_param "--shutdown=${USER_SHUTDOWN_SCRIPT}"
		return 0
	fi

	# no custum shutdown-script

	# test for good sudo-configuration
	if ! grep -q /usr/lib/vdr/bin/vdrshutdown-really.sh /etc/sudoers; then
		vdr_ewarn "  missing entry in /etc/sudoers"
		vdr_einfo
		vdr_einfo "  please add this line to your /etc/sudoers file"
		vdr_einfo "  vdr ALL=NOPASSWD:/usr/lib/vdr/bin/vdrshutdown-really.sh"
		shutdown_disabled
		return 0
	fi

	if [[ -f ${shutdown_script_dir}/wakeup-${WAKEUP_METHOD}.sh ]]; then
		# test if needed programs are there
		SHUTDOWN_EXITCODE=0
		source ${shutdown_script_dir}/wakeup-${WAKEUP_METHOD}.sh
		if [[ "${SHUTDOWN_EXITCODE}" != "0" ]]; then
			list_wakeup_methods
			shutdown_disabled
			return 0
		fi
	else
		vdr_eerror "  Wakeup-Method ${WAKEUP_METHOD} not supported!"
		list_wakeup_methods
		shutdown_disabled
		return 0
	fi

	add_param "--shutdown=/usr/lib/vdr/bin/vdrshutdown-gate.sh"
	return 0
}

