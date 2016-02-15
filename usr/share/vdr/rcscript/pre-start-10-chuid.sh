
addon_main() {
	yesno "${START_VDR_AS_ROOT}" && return 0

	if [ -n "${CAP_CHUID}" ] && ! yesno "${FORCE_SETUID_OFF}"; then
		ensure_param "--user" "-u"
		yesno ${ALLOW_USERDUMP} && ensure_param "--userdump"
	else
		add_daemonctrl_param --chuid vdr
	fi
	return 0
}
