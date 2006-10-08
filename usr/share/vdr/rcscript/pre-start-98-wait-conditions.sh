# $Id$
addon_main() {
	local exitcode=0
	if [[ "${waitconditions}" ]]; then
		ebegin "  Waiting for prerequisits (devices nodes etc.)" 
		waitfor 10 wait_for_multiple_condition
		exitcode="$?"
		exitmsg="could not start vdr"
		case "$exitcode" in
			1)
				exitmsg="${exitmsg}: ${condition_msg}"
				;;
			2)
				exitmsg="${exitmsg}: Timeout, ${condition_msg}"
				;;
		esac
		eend "$exitcode" "${exitmsg}"
	fi
	return $exitcode
}

