eval_standard_params() {
	[[ -n "${INTERNAL_WATCHDOG}" ]] && add_param "--watchdog=${WATCHDOG}"
	[[ -n "${AC3_AUDIO}" ]] && add_param "--audio=${AC3_AUDIO}"
	[[ -n "${MUTE}" ]] && add_param "--mute"
	[[ -n "${CONFIG}" ]] && add_param "--config=${CONFIG}"
	[[ -n "${DEVICE}" ]] && for i in ${DEVICE}; do add_param "--device=${i}"; done
	[[ -n "${EPGFILE}" ]] && add_param "--epgfile=${EPGFILE}"
	[[ -n "${LOG}" ]] && add_param "--log=${LOG}"
	[[ -z "${VIDEO}" ]] && VIDEO="/var/vdr/video"
	if [[ ! -d "${VIDEO}" ]]; then
		mkdir -p "${VIDEO}"
		chown vdr:vdr "${VIDEO}"
		einfo "Created directory ${VIDEO}"
	fi
	add_param "--video=${VIDEO}"
	[[ -n "${SVDRP_PORT}" ]] && add_param "--port=${SVDRP_PORT}"


	[[ -n "${RECORD_HOOK}" ]] && add_param "--record=${RECORD_HOOK}"

	if [[ -n "${TERMINAL}" ]]; then
		add_param "--terminal=${TERMINAL}"
		add_daemonctrl_param "--background"
	else
		add_param "--daemon"
	fi

	if [[ -n "${CAP_IRCTRL_RUNTIME_PARAM}" ]] && [[ -n "${IR_CTRL}" ]]; then
		case "${IR_CTRL}" in
			lirc|rcu) add_param "--${IR_CTRL}" ;;
		esac
	fi

	if [[ -n "${CAP_VFAT_RUNTIME_PARAM}" ]] && [[ "${VFAT_FILENAMES}" == "yes" ]]; then
		add_param "--vfat"
	fi
}

setup_shutdown() {
	source /etc/conf.d/vdr.shutdown
	[[ "${SHUTDOWN_ACTIVE:-no}" == "no" ]] && return

	if [[ -z "${USER_SHUTDOWN_SCRIPT}" ]]; then
		add_param "--shutdown=/usr/lib/vdr/bin/vdrshutdown-entry.sh"
		if ! grep -q /usr/lib/vdr/bin/vdrshutdown-really.sh /etc/sudoers; then
			ewarn "  missing entry in /etc/sudoers"
			einfo
			einfo "  please add this line to your /etc/sudoers file"
			einfo "  vdr ALL=NOPASSWD:/usr/lib/vdr/bin/vdrshutdown-really.sh"
		fi
	else
		add_param "--shutdown=${USER_SHUTDOWN_SCRIPT}"
	fi
}

eval_standard_params
setup_shutdown
