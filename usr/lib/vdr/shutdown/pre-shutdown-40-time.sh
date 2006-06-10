# $Id$

do_check_time() {
	if [[ -n ${BLOCK_SHUTDOWN_TIME} ]]; then
		include time
		check_interval NOW "${BLOCK_SHUTDOWN_TIME}"
		shutdown_abort_can_force "shutdown forbidden at the moment"
	fi
}

do_check_time

