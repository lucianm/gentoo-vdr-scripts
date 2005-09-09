eval_standard_params() {
	[[ -n "${INTERNAL_WATCHDOG}" ]] && add_param "--watchdog=${WATCHDOG}"
	[[ -n "${AC3_AUDIO}" ]] && add_param "--audio=${AC3_AUDIO}"
	[[ -n "${MUTE}" ]] && add_param "--mute"
	[[ -n "${CONFIG}" ]] && add_param "--config=${CONFIG}"
	[[ -n "${DEVICE}" ]] && for i in ${DEVICE}; do add_param "--device=${i}"; done
	[[ -n "${EPGFILE}" ]] && add_param "--epgfile=${EPGFILE}"
	[[ -n "${LOG}" ]] && add_param "--log=${LOG}"
	[[ -n "${VIDEO}" ]] && VIDEO="/var/vdr/video"
	add_param "--video=${VIDEO}"
	[[ -n "${SVDRP_PORT}" ]] && add_param "--port=${SVDRP_PORT}"

	[[ -n "${SHUTDOWN_HOOK}" ]] && add_param "--shutdown=${SHUTDOWN_HOOK}"
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
}


eval_standard_params
