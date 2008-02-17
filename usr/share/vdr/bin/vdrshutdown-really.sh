#!/bin/sh
# $Id$
# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#

#
# This script is called from vdrshutdown-gate.sh over sudo to
# have root-permissions for setting wakeup-time and triggering
# real shutdown/reboot.
#

. /usr/share/vdr/inc/functions.sh
include shutdown-functions

if [ "$(id -u)" != "0" ]; then
	echo "This program should be run as root"
	exit 99
fi

if [ "${DEBUG}" -ge 1 ]; then
	exec >/tmp/vdrshutdown-real-log 2>&1
	echo Started debug output of $0 $@
	set -x
fi

VDR_WAKEUP_TIME="${1}"

SVDRPCMD=/usr/bin/svdrpsend.pl

mesg() {
	if type logger >/dev/null 2>&1; then
		logger "$@"
	fi
}

# A little bit complicated, but this is used to really check if a reboot is needed
# nvram gets confused when setting the same time a second time
# (when first shutdown-try fails for some reason).

# to be called from wakeup-method to signalize need for reboot
set_reboot_needed() {
	date +%s > ${shutdown_data_dir}/shutdown-need-reboot
}

read_reboot_setting() {
	NEED_REBOOT=0
	[ -e "${shutdown_data_dir}/shutdown-need-reboot" ] || return
	local TSTAMP=$(cat ${shutdown_data_dir}/shutdown-need-reboot)
	local NOW=$(date +%s)

	local REBOOT_SET_AGO=$(( $NOW-$TSTAMP ))
	local UPTIME=$(cat /proc/uptime)
	UPTIME=${UPTIME%%.*}

	if [ "${REBOOT_SET_AGO}" -lt "${UPTIME}" ]; then
		NEED_REBOOT=1
	fi
}


WAKEUP_METHOD="${WAKEUP_METHOD:-rtc acpi nvram none}"

run_wakeup_method()
{
	local mod="$1"
	(
		if [ -f "${shutdown_script_dir}/wakeup-${mod}.sh" ]; then
			. ${shutdown_script_dir}/wakeup-${mod}.sh
		else
			return 1
		fi
	)
}

wakeup_ok=0
for method in ${WAKEUP_METHOD}; do
	if run_wakeup_method "${method}"; then
		wakeup_ok=1
		break
	fi
done
[ ${wakeup_ok} = 0 ] && exit 99

if [ "${DRY_SHUTDOWN_REAL}" = "1" ]; then
	exit 0
fi

read_reboot_setting

case "${NEED_REBOOT}" in
	1)	. ${shutdown_script_dir}/shutdown-reboot.sh ;;
	0)	. ${shutdown_script_dir}/shutdown-halt.sh ;;
esac

exit 0

