
include rc-functions

addon_main() {
	# parameters of start-stop-daemon
	[ -n "${VDR_NICENESS}" ] && add_daemonctrl_param --nicelevel "${VDR_NICENESS}"

	[ -n "${VDR_IONICE}" ] && add_daemonctrl_param --ionice "${VDR_IONICE}"

	if [ "${VDRVERSNUM}" -ge "20110" ]; then
		# Set command line option
		[ -n "${VDR_CHARSET_OVERRIDE}" ] && add_param "--chartab=${VDR_CHARSET_OVERRIDE}"
	else
		# Set environment // marked as deprecated up from vdr-2.1.10
		[ -n "${VDR_CHARSET_OVERRIDE}" ] && export VDR_CHARSET_OVERRIDE
	fi

	# parameters of vdr
	add_param "--watchdog=${INTERNAL_WATCHDOG:-60}"
	[ -n "${AC3_AUDIO}" ] && add_param "--audio=${AC3_AUDIO}"
	yesno "${MUTE}" && add_param "--mute"
	[ -n "${CONFIG}" ] && add_param "--config=${CONFIG}"
	[ -n "${DEVICE}" ] && for i in ${DEVICE}; do add_param "--device=${i}"; done
	[ -n "${EPGFILE}" ] && add_param "--epgfile=${EPGFILE}"

	if [ ! -d "${CACHEDIR:-/var/cache/vdr}" ]; then
		mkdir -p "${CACHEDIR:-/var/cache/vdr}"
		chown vdr:vdr "${CACHEDIR:-/var/cache/vdr}"
		einfo "Created directory ${CACHEDIR:-/var/cache/vdr}"
	fi
	add_param "--cachedir=${CACHEDIR:-/var/cache/vdr}"

	add_param "--log=${LOG:-1}"
	[ -z "${VIDEO}" ] && VIDEO="/var/lib/vdr/video"
	if [ ! -d "${VIDEO}" ]; then
		mkdir -p "${VIDEO}"
		chown vdr:vdr "${VIDEO}"
		einfo "Created directory ${VIDEO}"
	fi
	add_param "--video=${VIDEO}"
	[ -n "${SVDRP_PORT}" ] && add_param "--port=${SVDRP_PORT}"


	[ -n "${RECORD_HOOK}" ] && add_param "--record=${RECORD_HOOK}"

	if [ -n "${CAP_IRCTRL_RUNTIME_PARAM}" ] && [ -n "${IR_CTRL}" ]; then
		case "${IR_CTRL}" in
			lirc)	if [ -e /var/run/lirc/lircd ]; then
					add_param "--lirc=/var/run/lirc/lircd"
				else
					add_param "--lirc=/dev/lircd"
				fi
				;;
			rcu)	eerror "rcu parameter is obsolete"
					eerror "use media-plugins/vdr-rcu"
					logger -t vdr "rcu parameter is obsolete"
					logger -t vdr "use media-plugins/vdr-rcu"
				;;
		esac
	fi

	if [ -n "${CAP_VFAT_RUNTIME_PARAM}" ] && yesno "${VFAT_FILENAMES}"; then
		add_param "--vfat"
	fi

	add_param "--record=/usr/share/vdr/bin/vdrrecord-gate.sh"

	if [ -n "${VDR_EXTRA_OPTIONS}" ]; then
		add_param ${VDR_EXTRA_OPTIONS}
	fi
	return 0
}
