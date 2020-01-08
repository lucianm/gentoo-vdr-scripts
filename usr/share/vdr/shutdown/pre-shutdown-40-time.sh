
do_check_time() {
	if [ -n "${BLOCK_SHUTDOWN_INTERVALS}" ]; then
		include time
		if check_interval NOW "${BLOCK_SHUTDOWN_INTERVALS}"; then
			shutdown_abort_can_force "shutdown forbidden time"
		fi
	fi
}

do_check_time
