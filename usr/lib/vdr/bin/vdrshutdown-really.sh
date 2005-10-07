#!/bin/bash
# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#

shutdown_dir=/usr/lib/vdr/shutdown/

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

source /etc/conf.d/vdr.shutdown

WAKEUP_METHOD=${WAKEUP_METHOD:-acpi}

NEED_REBOOT=0
SHUTDOWN_EXITCODE=0

if [[ -f ${shutdown_dir}/wakeup-${WAKEUP_METHOD}.sh ]]; then
	source ${shutdown_dir}/wakeup-${WAKEUP_METHOD}.sh

	set_wakeup "${VDR_WAKEUP_TIME}"
else
	SHUTDOWN_EXITCODE=2
fi

[[ "${SHUTDOWN_EXITCODE}" != "0" ]] && exit ${SHUTDOWN_EXITCODE}


if [[ "${DUMMY}" == "1" ]]; then
	mesg "Dummy - not shutting down"
	exit 0
fi

case "${NEED_REBOOT}" in
	1)	source ${shutdown_dir}/shutdown-reboot.sh ;;
	0)	source ${shutdown_dir}/shutdown-halt.sh ;;
esac
