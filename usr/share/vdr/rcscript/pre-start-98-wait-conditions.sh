# $Id$
addon_main() {
	local exitcode=0
	if [ "${waitconditions}" ]; then
		ebegin "  Waiting for prerequisites (devices nodes etc.)" 
		waitfor 10 wait_for_multiple_condition
		exitcode="$?"
		exitmsg="Can not start VDR."
		case "$exitcode" in
			1)
				exitmsg="Timeout, can not start VDR."
				;;
		esac
		eend "$exitcode" "${exitmsg}"
		[ -n "${condition_msg}" ] && ewarn "${condition_msg}"
		[ "$(type -t "${condition_msg_func}")" = "function" ] && eval "${condition_msg_func}"
	fi
	return $exitcode
}
