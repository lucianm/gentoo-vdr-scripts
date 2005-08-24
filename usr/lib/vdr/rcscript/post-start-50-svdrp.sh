wait_for_svdrp() {
	SVDRP_PORT="${SVDRP_PORT:-2001}"
	[[ "${SVDRP_PORT}" == "0" ]] && return

	# Warten auf offenen svdrp port
	waitfor 20 svdrpready

	case "$?" in
	1)
		exit_msg="timeout"
		abort=1
		;;
	2)
		exit_msg="aborted, please check logfile"
		abort=2
		;;
	esac
}

svdrpready() {
	if /usr/bin/svdrpsend.pl -d localhost -p ${SVDRP_PORT} quit 2>/dev/null|grep -q ^220; then
		# svdrp open and ready
		return 0
	fi
	if ! test_vdr_process; then
		# Not running
		return 2
	fi
	return 1
}

wait_for_svdrp
