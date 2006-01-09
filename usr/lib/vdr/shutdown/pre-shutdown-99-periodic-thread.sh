# $Id$
source /etc/conf.d/vdr.periodic.general

PERIODIC_THREAD_ENDTIME=${shutdown_data_dir}/periodic_thread_last_ended


check_periodic_thread()
{
	# test if periodic thread is activated
	: ${ENABLE_SHUTDOWN_PERIODIC_JOBS:=no}
	[[ ${ENABLE_SHUTDOWN_PERIODIC_JOBS} == "yes" ]] || return

	# when periodic-thread runs
	local PIDOF=pidof
	if ${PIDOF} -x vdrshutdown-periodic-thread.sh >/dev/null; then
		# stop shutdown which can be forced
		shutdown_abort_can_force "periodic jobs are waiting"

		# kill it if forced
		if [[ ${THIS_SHUTDOWN_IS_FORCED} == 1 ]]; then
			killall vdrshutdown-periodic-thread.sh
		fi
	fi

	# do not continue if shutdown is forced
	[[ ${THIS_SHUTDOWN_IS_FORCED} == 1 ]] && return

	#is_auto_shutdown || return

	local NOW=$(date +%s)
	local MINIMAL_THREAD_CALL_DELTA=$(( 3600*20 ))

	local LAST_THREAD_END=0
	[[ -f ${PERIODIC_THREAD_ENDTIME} ]] && LAST_THREAD_END=$(<${PERIODIC_THREAD_ENDTIME})
	
	local DELTA=$(( NOW-LAST_THREAD_END ))

	# do not start if has been run in the last 20 hours
	[[ ${DELTA} -lt ${MINIMAL_THREAD_CALL_DELTA} ]] && return

	# starting thread aborts shutdown
	shutdown_abort "periodic jobs are waiting"
	disable_auto_retry

	# can take longer time
	/usr/lib/vdr/bin/vdr-bg.sh /usr/lib/vdr/bin/vdrshutdown-periodic-thread.sh &
}

check_periodic_thread

