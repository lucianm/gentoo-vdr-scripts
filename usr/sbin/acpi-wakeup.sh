#!/bin/sh
# $Id$

##
# based on vdrshutdown-acpi.pl
# by Thomas Koch <tom@linvdr.org>
##

# Author:
#  Matthias Schwarzott <zzam at gmx dot de>
#
# Parameter:
#  $1 : Time to be up and running as unix-timestamp
#

PROC_ALARM="/proc/acpi/alarm"
RTC_ALARM="/sys/class/rtc/rtc0/wakealarm"

#DEBUG=1
[ -z "$DEBUG" ] && DEBUG=0

die()
{
	echo "ERROR: $@" 1>&2
	exit 1
}

checkUTC()
{
	unset CLOCK
	if [ -f /etc/conf.d/clock ]; then
		CLOCK=$(. /etc/conf.d/clock; echo ${CLOCK})
	else
		CLOCK=$(. /etc/rc.conf; echo ${CLOCK})
	fi
	[ "${CLOCK}" = "UTC" ]
}

saveTime()
{
	local param
	[ "$DEBUG" = "1" ] || param=--quiet
	/etc/init.d/clock $param save
}

setAlarm()
{
	local timestamp
	if [ "${Next}" -gt 0 ]; then
		# abort if recording less then 10min in future
		local now=$(date +%s)
		[ "${Next}" -lt "$(($now+600))" ] && die "wakeup time too near, alarm not set"

		# boot 5min (=300s) before recording
		timestamp=$(($Next-300))
	else
		timestamp=0
	fi

	# write time to RTC now, as it may disable wakeup if done after writing alarm time
	saveTime

	# new interface Kernel 2.6.22+
	if [ -e ${RTC_ALARM} ]; then
		local timestr=${timestamp}
		# maybe this needs to be adjusted if bios time is not in UTC

		# clear old time
		echo 0 > ${RTC_ALARM}
		echo "${timestr}" > ${RTC_ALARM}
		return
	fi
		
	# old interface
	if [ -e ${PROC_ALARM} ]; then
		# This hopefully deactivates wakeup
		local timestr="2003-10-20 99:00:00"

		if [ ${timestamp} -gt 0 ]; then
			checkUTC && dateparam="-u"
			timestr=$(date ${dateparam} --date="1970-01-01 UTC ${timestamp} seconds" +"%Y-%m-%d %H:%M:00")
			[ -z "${timestr}" ] && die "date did not return a string"
		fi

		# write 2 times
		echo ${timestr} > ${PROC_ALARM}
		echo ${timestr} > ${PROC_ALARM}
		return
	fi

	die "Kernel does not support ACPI alarm"
}



test $# -ge 1 || die "Wrong Parameter Count"
Next="${1}"
Delta="${2}"
RecordName="${3}"

setAlarm
exit 0
