PERIODIC_THREAD_ENDTIME=${shutdown_data_dir}/periodic_thread_last_ended


check_periodic_thread()
{
	local PIDOF=pidof
	if ${PIDOF} -x vdrshutdown-periodic-thread.sh >/dev/null; then
		shutdown_abort_can_force "periodic shutdown-thread is running"
	fi
	
	: ${ENABLE_SHUTDOWN_PERIODIC_THREAD:=no}
	
	[[ ${ENABLE_SHUTDOWN_PERIODIC_THREAD} == "yes" ]] || return

	[[ "${SHUTDOWN_ABORT}" == "1" ]] && return

	is_auto_shutdown || return

	local NOW=$(date +%s)
	local MINIMAL_THREAD_CALL_DELTA=$(( 3600*20 ))

	local LAST_THREAD_END=0
	[[ -f ${PERIODIC_THREAD_ENDTIME} ]] && LAST_THREAD_END=$(<${PERIODIC_THREAD_ENDTIME})
	
	local DELTA=$(( NOW-LAST_THREAD_END ))

	[[ ${DELTA} -lt ${MINIMAL_THREAD_CALL_DELTA} ]] && return
	
	# can take longer time
	/usr/lib/vdr/bin/vdr-bg.sh /usr/lib/vdr/shutdown/vdrshutdown-periodic-thread.sh &
	
	exit 0
}

check_periodic_thread

