
include rc-functions
include argsdir-functions
include runtimedirs-functions

addon_main() {
	# parameters of start-stop-daemon
	[ -n "${VDR_NICENESS}" ] && add_daemonctrl_param --nicelevel "${VDR_NICENESS}"

	[ -n "${VDR_IONICE}" ] && add_daemonctrl_param --ionice "${VDR_IONICE}"

	ensure_cache_dir

	[ -z "${VIDEO}" ] && VIDEO="${vdr_user_home}/video"

	ensure_video_dir

	if [ -n "${CAP_IRCTRL_RUNTIME_PARAM}" ] && [ -n "${IR_CTRL}" ]; then
		case "${IR_CTRL}" in
			lirc)	if [ -e /var/run/lirc/lircd ]; then
					ensure_param "--lirc=/var/run/lirc/lircd"
				else
					ensure_param "--lirc=/dev/lircd"
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
		ensure_param "--vfat"
	fi
	return 0
}
