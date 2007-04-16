# $Id$

#
# Only contains checking of time-intervals for
# shutdown-check called BLOCK_SHUTDOWN_INTERVALS
#

time2min() {
	local t=${1}
	if [ "$t" = "NOW" ]; then
		t=$(date +%H:%M)
	fi

	# alles vor :
	local h=${t%:*}
	h=${h##0}

	# alles nach :
	local m=${t#*:}
	m=${m##0}

	# Wenn die Zeit kein ":" enthaelt
	[ "$m" = "$t" ] && m=0

	echo $(( ( h*60 + m ) % 1440 ))
}

#
# Checks a given time hh:mm against a list of intervals
# Interval: hh[:mm][-hh[:mm]]
# e.g. INTERVALS="2:00-3:47 8-23:9"
#
# bool check_interval (point, intervals)
check_interval() {
	local testtime=$(time2min ${1})
	local intervals="${2}"

	local nr=0
	local INSIDE=0
	for i in $intervals; do
		: $((nr++))
		local HIT=0
		case ${i} in
		*-*)
			local start=${i%-*}
			local stop=${i#*-}
			start=$(time2min $start)
			stop=$(time2min $stop)

			if [ "$start" -le "$stop" ]; then
				# if (start <= testtime <= stop)
				if [ "$start" -le "$testtime" ] && [ "$testtime" -le "$stop" ]; then
					HIT=1
				fi
			else
				# itervall ueber mitternacht
				# if ( 0 <= testtime <= stop ) || ( start <= testtime <= midnight)
				if [ "$testtime" -le "$stop" ] || [ "$start" -le "$testtime" ]; then
					HIT=1
				fi
			fi
			;;
		*)
			local point=$(time2min $i)
			if [ "$start" -eq "$testtime" ]; then
				HIT=1
			fi
			;;
		esac
		if [ "$HIT" = 1 ]; then
			: $((INSIDE++))
		fi
	done
	if [ "$INSIDE" -gt 0 ]; then
		return 0
	else
		return 1
	fi
}

