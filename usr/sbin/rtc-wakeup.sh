#!/bin/sh
# $Id: acpi-wakeup.sh 571 2007-12-10 20:50:11Z zzam $

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

RTC_ALARM="/sys/class/rtc/rtc0/wakealarm"

die() {
	echo "ERROR: $@" 1>&2
	exit 1
}

if [ ! -w "${RTC_ALARM}" ]; then
	die "Can not access acpi-rtc-clock."
fi

test $# -ge 1 || die "Wrong Parameter Count"
Next="${1}"

# clear old time
echo 0 > "${RTC_ALARM}"

if [ "${Next}" -eq 0 ]; then
	# already disabled, we are done
	exit 0
fi

# abort if recording less then 10min in future
now=$(date +%s)
[ "${Next}" -lt "$(($now+600))" ] && die "wakeup time too near, alarm not set"

# boot 5min (=300s) before recording
timestamp=$(($Next-300))

# maybe this needs to be adjusted if bios time is not in UTC
echo "${timestamp}" > "${RTC_ALARM}"

exit 0
