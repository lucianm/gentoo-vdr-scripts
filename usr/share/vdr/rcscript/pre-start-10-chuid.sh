# $Id$
addon_main() {
	if [ "${START_VDR_AS_ROOT}" != "YES" ]; then
		if [ -n "${CAP_CHUID}" -a "${FORCE_SETUID_OFF:-no}" = "no" ]; then
			add_param "-u" "vdr"
		else
			add_daemonctrl_param --chuid vdr
		fi
	fi
	return 0
}

