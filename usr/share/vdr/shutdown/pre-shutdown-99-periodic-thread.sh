# $Id$
. /etc/conf.d/vdr.periodic.general

PERIODIC_THREAD_ENDTIME=${shutdown_data_dir}/periodic_thread_last_ended

check_periodic_thread() {
	# test if periodic thread is activated
	yesno "${ENABLE_SHUTDOWN_PERIODIC_JOBS}" || return

	# when periodic-thread runs
	if pidof -x vdrshutdown-periodic-thread.sh >/dev/null; then
		# stop shutdown which can be forced
		shutdown_abort_can_force "periodic jobs are waiting"

		# kill it if forced
		if is_forced_shutdown; then
			killall vdrshutdown-periodic-thread.sh
		fi
	fi

	# do not continue if shutdown is forced
	is_forced_shutdown && return

	#is_auto_shutdown || return

	local NOW=$(date +%s)
	local MINIMAL_THREAD_CALL_DELTA=$(( 3600*20 ))

	local LAST_THREAD_END=$(read_int_from_file "${PERIODIC_THREAD_ENDTIME}")
	
	local DELTA=$(( $NOW-$LAST_THREAD_END ))

	# do not start if has been run in the last 20 hours
	[ "${DELTA}" -lt "${MINIMAL_THREAD_CALL_DELTA}" ] && return

	# starting thread aborts shutdown
	shutdown_abort_can_force "periodic jobs are waiting"
	disable_auto_retry

	# can take longer time
	/usr/share/vdr/bin/vdr-bg.sh /usr/share/vdr/bin/vdrshutdown-periodic-thread.sh &
}

check_periodic_thread
