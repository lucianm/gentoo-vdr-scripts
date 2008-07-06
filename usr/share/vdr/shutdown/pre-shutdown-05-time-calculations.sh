# $Id:$

: ${FIXED_WAKEUP:=no}
: ${FIXED_WAKEUP_TIME:="02:00:00"}

print_localtime ()
{
	date --date="1970-01-01 UTC ${1} seconds"
}

catch_running_timer()
{
	local NOW=$(date +%s)

	# Do not wake up on events in past
	# Better strategy would be to manually scan the list of timers
	# for the first active in future
	# for now abort the shutdown

	# if timer_exists && timer in past; then
	if [ "${VDR_TIMER_NEXT}" -ne 0 -a "${VDR_TIMER_NEXT}" -le "${NOW}" ]; then
		#VDR_TIMER_NEXT=0
		disable_auto_retry
		shutdown_abort "timer is running"
	fi
}

calculate_wakeup_timer ()
{
	local NEXT_FIXED_WAKEUP=$(date --date=${FIXED_WAKEUP_TIME} +%s)
	local NOW=$(date +%s)

	if [ "${NOW}" -gt "${NEXT_FIXED_WAKEUP}" ]; then
		NEXT_FIXED_WAKEUP=$(date --date="tomorrow ${FIXED_WAKEUP_TIME}" +%s)
	fi

	logger "Next timer at $(print_localtime ${VDR_TIMER_NEXT})"
	if [ "${NEXT_FIXED_WAKEUP}" -lt "${VDR_TIMER_NEXT}" ] \
	      || [ "${NOW}" -gt "${VDR_TIMER_NEXT}" ]; then
		VDR_TIMER_NEXT=${NEXT_FIXED_WAKEUP}
		logger "Modified wakeup time to $(print_localtime ${VDR_TIMER_NEXT})"
	else
		logger "Leaving wakeup time unchanged ($(print_localtime ${VDR_TIMER_NEXT}))"
	fi
}

catch_running_timer
if yesno "${FIXED_WAKEUP}"; then
	calculate_wakeup_timer
fi

