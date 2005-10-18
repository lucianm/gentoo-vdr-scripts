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

	# Check if TERMINAL is set and a valid character-device
	if [[ -n "${TERMINAL}" ]]; then
		if [[ ! -c "${TERMINAL}" ]]; then
			ewarn "Terminal ${TERMINAL} not existing"
			TERMINAL="/dev/null"
		fi
	else
		TERMINAL="/dev/null"
	fi
	#add_daemonctrl_param "--background"

	if [[ -n "${CAP_IRCTRL_RUNTIME_PARAM}" ]] && [[ -n "${IR_CTRL}" ]]; then
		case "${IR_CTRL}" in
			lirc|rcu) add_param "--${IR_CTRL}" ;;
		esac
	fi

	if [[ -n "${CAP_VFAT_RUNTIME_PARAM}" ]] && [[ "${VFAT_FILENAMES}" == "yes" ]]; then
		add_param "--vfat"
	fi

	add_param "--record=/usr/lib/vdr/bin/vdrrecord-gate.sh"
}

eval_standard_params
