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
#DEBUG=1
[ -z "$DEBUG" ] && DEBUG=0

die()
{
	echo $@ 1>&2
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
	[ "${DEBUG}" = "1" ] && echo CLOCK-MODE: ${CLOCK}
}

saveTime()
{
	local param
	[ "$DEBUG" = "1" ] || param=--quiet
	/etc/init.d/clock $param save
}

setAlarm()
{
	checkUTC
	local timestr
	if [ "${Next}" -gt 0 ]; then
		# abort if recording less then 10min in future
		local now=$(date +%s)
		[ "${Next}" -lt "$(($now+600))" ] && die "wakeup time too near, alarm not set"

		# boot 5min (=300s) before recording
		local t=$(($Next-300))

		[ "${CLOCK}" = "UTC" ] && dateparam="-u"
		timestr=$(date ${dateparam} --date="1970-01-01 UTC ${t} seconds" +"%Y-%m-%d %H:%M:00")
	else
		# This hopefully deactivates wakeup
		timestr="2003-10-20 99:00:00"
	fi

	[ -z "${timestr}" ] && return

	saveTime

	echo ${timestr} > ${PROC_ALARM} 
	echo ${timestr} > ${PROC_ALARM} 

	if [ "${DEBUG}" = "1" ]; then
		echo ${timestr} > /tmp/a
		echo Wakeup at ${timestr} >> /tmp/a
	fi
}



test -f "${PROC_ALARM}" || die "${PROC_ALARM} missing"
test $# -ge 1 || die "Wrong Parameter Count"
Next="${1}"
Delta="${2}"
RecordName="${3}"

setAlarm
exit 0
