PERIODIC_THREAD_STARTTIME=${shutdown_data_dir}/periodic_thread_last_started


check_periodic_thread()
{
	: ${ENABLE_SHUTDOWN_PERIODIC_THREAD:=no}
	
	[[ ${ENABLE_SHUTDOWN_PERIODIC_THREAD} == "yes" ]] || return

	[[ "${SHUTDOWN_ABORT}" == "1" ]] && return

	is_auto_shutdown || return

	local NOW=$(date +%s)
	local MINIMAL_THREAD_CALL_DELTA=$(( 3600*20 ))

	local LAST_THREAD_START=0
	[[ -f ${PERIODIC_THREAD_STARTTIME} ]] && LAST_THREAD_START=$(<${PERIODIC_THREAD_STARTTIME})
	
	local DELTA=$(( NOW-LAST_THREAD_START ))

	[[ ${DELTA} -lt ${MINIMAL_THREAD_CALL_DELTA} ]] && return
	
	# can take longer time
	echo ${NOW} > ${PERIODIC_THREAD_STARTTIME}
	/usr/lib/vdr/bin/vdr-bg.sh /usr/lib/vdr/shutdown/vdrshutdown-periodic-thread.sh &
	
	exit 0
}

check_periodic_thread

