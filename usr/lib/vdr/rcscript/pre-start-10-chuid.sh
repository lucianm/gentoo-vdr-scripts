addon_main() {
	if [[ "${START_VDR_AS_ROOT}" == "YES" ]]; then
		if [[ -n ${CAP_CHUID} ]]; then
			add_param "-u root"
		else
			:
			# vdr does nothing and stays root
		fi
	else
		if [[ -n ${CAP_CHUID} ]]; then
			add_param "-u vdr"
		else
			add_daemonctrl_param --chuid vdr
		fi
	fi
}

