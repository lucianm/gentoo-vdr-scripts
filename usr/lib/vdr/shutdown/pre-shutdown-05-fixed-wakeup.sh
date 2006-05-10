# $Id:$

: ${FIXED_WAKEUP:=no}
: ${FIXED_WAKEUP_TIME:="02:00:00"}

print_localtime ()
{
	date --date="1970-01-01 UTC ${1} seconds"
}

calculate_wakeup_timer ()
{
	local NEXT_FIXED_WAKEUP=$(date --date=${FIXED_WAKEUP_TIME} +%s)
	local NOW=$(date +%s)

	if [[ ${NOW} > ${NEXT_FIXED_WAKEUP} ]]; then
		NEXT_FIXED_WAKEUP=$(date --date="tomorrow ${FIXED_WAKEUP_TIME}" +%s)
	fi

	logger "Next timer at $(print_localtime ${VDR_TIMER_NEXT})"
	if [[ ${NEXT_FIXED_WAKEUP} < ${VDR_TIMER_NEXT} \
	      || ${NOW} > ${VDR_TIMER_NEXT} ]]; then
		VDR_TIMER_NEXT=${NEXT_FIXED_WAKEUP}
		logger "Modified wakeup time to $(print_localtime ${VDR_TIMER_NEXT})"
	else
		logger "Leaving wakeup time unchanged ($(print_localtime ${VDR_TIMER_NEXT}))"
	fi
}

if [[ "${FIXED_WAKEUP:-no}" == "yes" ]]; then
	calculate_wakeup_timer
fi

