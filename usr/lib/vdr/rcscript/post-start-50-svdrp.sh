wait_for_svdrp() {
	SVDRP_PORT="${SVDRP_PORT:-2001}"
	SVDRP_HOSTNAME="${SVDRP_HOSTNAME:-localhost}"
	[[ "${SVDRP_PORT}" == "0" ]] && return
	ebegin "  Waiting for working vdr"

	# Warten auf offenen svdrp port
	waitfor 20 svdrpready

	case "$?" in
	1)
		exit_msg="timeout, hoping its running good nevertheless"
		;;
	2)
		exit_msg="aborted, please check logfile"
		abort=2
		;;
	esac
	eend ${abort} "${exit_msg}" 
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
}

