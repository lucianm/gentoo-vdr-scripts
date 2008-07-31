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

if [ "$(id -u)" != "0" ]; then
	echo "This program should be run as root"
	exit 99
fi

. /usr/share/vdr/inc/functions.sh
include shutdown-functions
shutdown_script_dir=/usr/share/vdr/shutdown

if [ "${DEBUG}" -ge 1 ]; then
	exec >/tmp/vdrshutdown-wakeup-helper.log 2>&1
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

need_reboot() {
	[ -e "${shutdown_data_dir}/shutdown-need-reboot" ] || return
	local TSTAMP=$(cat ${shutdown_data_dir}/shutdown-need-reboot)
	local NOW=$(date +%s)

	local REBOOT_SET_AGO=$(( $NOW-$TSTAMP ))
	local UPTIME=$(cat /proc/uptime)
	UPTIME=${UPTIME%%.*}

	if [ "${REBOOT_SET_AGO}" -lt "${UPTIME}" ]; then
		return 0
	fi

	return 1
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


SHUTDOWN_METHOD=halt
if need_reboot; then
	SHUTDOWN_METHOD=reboot
fi

f="${shutdown_script_dir}/shutdown-${SHUTDOWN_METHOD}.sh"

if [ "${DRY_SHUTDOWN}" = "1" ]; then
	echo "dry run: NOT executing shutdown-${SHUTDOWN_METHOD}.sh"
	exit 0
fi

if [ -f "$f" ]; then
	echo "Executing shutdown-${SHUTDOWN_METHOD}.sh"
	. "$f"
fi

exit 0

