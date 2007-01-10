# $Id$

list_wakeup_methods() {
	local methods
	local m
	for m in ${shutdown_script_dir}/wakeup-*.sh; do
		m="${m##*wakeup-}"
		m="${m%.sh}"
		methods="${methods} ${m}"
	done
	vdr_einfo "    Available shutdown methods:${methods}"
	vdr_einfo "    There are some useflags to enable more shutdown methods."
	vdr_einfo "    You have to reemerge gentoo-vdr-scripts with the new use-flags set."
}

addon_main() {
	include shutdown-functions
	[[ "${SHUTDOWN_ACTIVE}" == "no" ]] && return 0

	if [[ -n "${USER_SHUTDOWN_SCRIPT}" ]]; then
		add_param "--shutdown=${USER_SHUTDOWN_SCRIPT}"
		return 0
	fi

	# no custum shutdown-script
	add_param "--shutdown=/usr/share/vdr/bin/vdrshutdown-gate.sh"

	# some sanity warnings
	if ! grep -q /usr/share/vdr/bin/vdrshutdown-really.sh /etc/sudoers; then
		vdr_ewarn "  missing entry in /etc/sudoers"
		vdr_ewarn
		vdr_ewarn "  please add this line to your /etc/sudoers file"
		vdr_ewarn "  vdr ALL=NOPASSWD:/usr/share/vdr/bin/vdrshutdown-really.sh"
		vdr_ewarn
		vdr_ewarn "  or call emerge --config gentoo-vdr-scripts"
		vdr_ewarn
	fi

	if [[ -f ${shutdown_script_dir}/wakeup-${WAKEUP_METHOD}.sh ]]; then
		source ${shutdown_script_dir}/wakeup-${WAKEUP_METHOD}.sh

		# test if needed programs are there
		if ! wakeup_check; then
			list_wakeup_methods
		fi
	else
		vdr_eerror "  Wakeup-Method ${WAKEUP_METHOD} not supported!"
		list_wakeup_methods
	fi

	return 0
}

