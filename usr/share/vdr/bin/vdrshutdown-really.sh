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
	logger $@
	${SVDRPCMD} MESG "\"$@\""
}

error_mesg() {
	mesg "Error: $@"
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



if [ -f "${shutdown_script_dir}/wakeup-${WAKEUP_METHOD}.sh" ]; then
	. ${shutdown_script_dir}/wakeup-${WAKEUP_METHOD}.sh

	wakeup_check || exit 99
	wakeup_set "${VDR_WAKEUP_TIME}" || exit 99
else
	exit 98
fi


if [ "${DRY_SHUTDOWN_REAL}" = "1" ]; then
	mesg "Dry-run - not shutting down"
	exit 0
fi

read_reboot_setting

case "${NEED_REBOOT}" in
	1)	. ${shutdown_script_dir}/shutdown-reboot.sh ;;
	0)	. ${shutdown_script_dir}/shutdown-halt.sh ;;
esac
