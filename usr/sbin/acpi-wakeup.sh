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

die()
{
	echo "ERROR: $@" 1>&2
	exit 1
}

checkUTC()
{
	unset clock
	unset CLOCK
	local f
	for f in /etc/conf.d/hwclock /etc/conf.d/clock /etc/rc.conf; do
		if [ -f "${f}" ]; then
			. "${f}"
			break
		fi
	done
	clock="${clock:-${CLOCK}}"

	[ "${clock}" = "UTC" ]
}

writeAlarm()
{
	# write 2 times (some bioses need this)
	echo "$1" > "${PROC_ALARM}"
	echo "$1" > "${PROC_ALARM}"
}


# main part starts here

if [ ! -w "${PROC_ALARM}" ]; then
	die "Can not access ${PROC_ALARM}."
fi

test $# -ge 1 || die "Wrong Parameter Count"
# time the system should be up
Next="${1}"

# write time to RTC now, as it may disable wakeup if done after writing alarm time
if [ -x /etc/init.d/hwclock ]; then
	/etc/init.d/hwclock --quiet save
else
	/etc/init.d/clock --quiet save
fi

if [ "${Next}" -eq 0 ]; then
	# This hopefully deactivates wakeup
	writeAlarm "2003-10-20 99:00:00"
	exit 0
fi

# abort if recording less then 10min in future
now=$(date +%s)
[ "${Next}" -lt "$(($now+600))" ] && die "wakeup time too near, alarm not set"

# boot 5min (=300s) before recording
timestamp=$(($Next-300))
checkUTC && dateparam="-u"

timestr=$(date ${dateparam} --date="1970-01-01 UTC ${timestamp} seconds" +"%Y-%m-%d %H:%M:00")
[ -z "${timestr}" ] && die "date did not return a string"

writeAlarm "${timestr}"

exit 0
