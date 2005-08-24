eval_standard_params() {
	[ -n "${WATCHDOG}" ] && add_param "--watchdog=${WATCHDOG}"
	[ -n "${AC3_AUDIO}" ] && add_param "--audio=${AC3_AUDIO}"
	[ -n "${MUTE}" ] && add_param "--mute"
	[ -n "${CONFIG}" ] && add_param "--config=${CONFIG}"
	[ -n "${DEVICE}" ] && for i in ${DEVICE}; do add_param "--device=${i}"; done
	[ -n "${EPGFILE}" ] && add_param "--epgfile=${EPGFILE}"
	[ -n "${LOG}" ] && add_param "--log=${LOG}"
	[ -n "${VIDEO}" ] && add_param "--video=${VIDEO}"
	[ -n "${SVDRP_PORT}" ] && add_param "--port=${SVDRP_PORT}"

	[ -n "${SHUTDOWN_HOOK}" ] && add_param "--shutdown=${SHUTDOWN_HOOK}"
	[ -n "${RECORD_HOOK}" ] && add_param "--record=${RECORD_HOOK}"
}


eval_standard_params
