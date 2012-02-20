# $Id$

include rc-functions

include svdrpcmd
svdrp_command

addon_main() {
	# we already know vdr failed
	[ "${vdr_start_failed}" = "1" ] && return 0

	if [ "${VDRVERSNUM}" -ge "10715" ]; then
		SVDRP_PORT="${SVDRP_PORT:-6419}"
		logger -t vdr "New default svdrp port 6419!"
	else
		SVDRP_PORT="${SVDRP_PORT:-2001}"
	fi

	SVDRP_HOSTNAME="${SVDRP_HOSTNAME:-localhost}"
	[ "${SVDRP_PORT}" = "0" ] && return 0

	if [ ! -e /etc/vdr/remote.conf ]; then
		einfo "First start of vdr: No check for running vdr possible"
		einfo "until control device (remote/keyboard) keys are learnt!"
		return 0
	fi

	ebegin "  Waiting for working vdr"

	# Warten auf offenen svdrp port
	START_SVDRP_WAIT_SECONDS=${START_SVDRP_WAIT_SECONDS:-40}

	waitfor ${START_SVDRP_WAIT_SECONDS} svdrp_ready

	case "$?" in
	0)	eend 0
		;;
	1)	eend 1 "timeout. Hoping that VDR is running good nevertheless."
		einfo
		einfo "Ignore this if you connected a new remote/keyboard which gets learned."
		einfo "If your computer is very slow it is possible that vdr"
		einfo "needs more than ${START_SVDRP_WAIT_SECONDS} seconds to be up and going."
		einfo "You can enlarge that value inside /etc/conf.d/vdr (START_SVDRP_WAIT_SECONDS)."
		einfo
		# continue with state "started"
		;;
	2)	eend 2 "VDR process died, please check logfile"
		# tell init-script that vdr died
		vdr_exitcode=1
		;;
	esac

	return 0
}

svdrp_ready() {
	if ${SVDRPCMD} -d ${SVDRP_HOSTNAME} -p ${SVDRP_PORT} quit 2>/dev/null|grep -q ^220; then
		# svdrp open and ready
		return 0
	fi
	if ! test_vdr_process; then
		# Not running
		return 2
	fi
	return 1
}
