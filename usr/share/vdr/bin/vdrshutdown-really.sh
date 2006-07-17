#!/bin/bash
# $Id$
# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#

#
# This script is called from vdrshutdown-gate.sh over sudo to
# have root-permissions for setting wakeup-time and triggering
# real shutdown/reboot.
#

source /usr/share/vdr/inc/functions.sh
include shutdown-functions

if [[ "${UID}" != "0" ]]; then
	echo "This program should be run as root"
	exit 1
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

SHUTDOWN_EXITCODE=0

set_reboot_needed() {
	date +%s > ${shutdown_data_dir}/shutdown-need-reboot
}

read_reboot_setting() {
	NEED_REBOOT=0
	[[ -e ${shutdown_data_dir}/shutdown-need-reboot ]] || return
	local TSTAMP=$(<${shutdown_data_dir}/shutdown-need-reboot)
	local NOW=$(date +%s)

	local REBOOT_SET_AGO=$(( NOW-TSTAMP ))
	local UPTIME=$(</proc/uptime)
	UPTIME=${UPTIME/.*/}

	if [[ ${REBOOT_SET_AGO} -lt ${UPTIME} ]]; then
		NEED_REBOOT=1
	fi
}

if [[ -f ${shutdown_script_dir}/wakeup-${WAKEUP_METHOD}.sh ]]; then
	source ${shutdown_script_dir}/wakeup-${WAKEUP_METHOD}.sh

	set_wakeup "${VDR_WAKEUP_TIME}"
else
	SHUTDOWN_EXITCODE=2
fi

[[ "${SHUTDOWN_EXITCODE}" != "0" ]] && exit ${SHUTDOWN_EXITCODE}


if [[ "${DUMMY}" == "1" ]]; then
	mesg "Dummy - not shutting down"
	exit 0
fi

read_reboot_setting

case "${NEED_REBOOT}" in
	1)	source ${shutdown_script_dir}/shutdown-reboot.sh ;;
	0)	source ${shutdown_script_dir}/shutdown-halt.sh ;;
esac
