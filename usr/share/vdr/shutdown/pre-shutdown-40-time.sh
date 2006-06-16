# $Id$

do_check_time() {
	if [[ -n ${BLOCK_SHUTDOWN_INTERVALS} ]]; then
		include time
		check_interval NOW "${BLOCK_SHUTDOWN_INTERVALS}"
		shutdown_abort "shutdown forbidden time"
	fi
}

do_check_time

