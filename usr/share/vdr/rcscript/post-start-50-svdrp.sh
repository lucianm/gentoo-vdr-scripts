# $Id$
wait_for_svdrp() {
	local ret=0
	SVDRP_PORT="${SVDRP_PORT:-2001}"
	SVDRP_HOSTNAME="${SVDRP_HOSTNAME:-localhost}"
	[[ "${SVDRP_PORT}" == "0" ]] && return 0

	if [[ ! -e /etc/vdr/remote.conf ]]; then
		einfo "First start of vdr: No check for running vdr possible"
		einfo "until control device (remote/keyboard) keys are learnt!"
		return 0
	fi

	ebegin "  Waiting for working vdr"

	# Warten auf offenen svdrp port
	: ${START_SVDRP_WAIT_SECONDS:=40}
	waitfor ${START_SVDRP_WAIT_SECONDS} svdrpready
	ret=$?

	local msg_for_error="aborted, please check logfile"

	case "$ret" in
	1)	eend ${ret} "timeout, hoping its running good nevertheless"
		einfo
		einfo "Ignore this if you connected new remote/keyboard which gets learned."
		einfo "If your computer is very slow it is possible that vdr"
		einfo "needs more than ${START_SVDRP_WAIT_SECONDS} seconds to be up and going."
		einfo "You can enlarge that value inside /etc/conf.d/vdr (START_SVDRP_WAIT_SECONDS)."
		einfo
		ret=0
		# continue with state "started"
		;;
	*)
		eend ${ret} "aborted, please check logfile"
	esac
	return $ret
}

svdrpready() {
	if /usr/bin/svdrpsend.pl -d ${SVDRP_HOSTNAME} -p ${SVDRP_PORT} quit 2>/dev/null|grep -q ^220; then
		# svdrp open and ready
		return 0
	fi
	if ! test_vdr_process; then
		# Not running
		return 2
	fi
	return 1
}

addon_main() {
	wait_for_svdrp
	ret="$?"
	case "$ret" in
	1) ret=0; ;;
	esac
	return ${ret}
}

