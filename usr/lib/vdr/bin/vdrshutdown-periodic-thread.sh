#!/bin/bash
# $Id$

source /usr/lib/vdr/inc/functions.sh
include shutdown-functions
read_caps

THREAD_DIR=/usr/lib/vdr/shutdown
PERIODIC_THREAD_ENDTIME=${shutdown_data_dir}/periodic_thread_last_ended

SVDRPSEND=/usr/bin/svdrpsend.pl

mesg() {
	${SVDRPSEND} mesg "${1}"
}

sleep 15s
mesg "periodic thread started"

for HOOK in ${THREAD_DIR}/periodic-*.sh; do
	[[ -f "${HOOK}" ]] && source "${HOOK}"
done

NOW=$(date +%s)
echo ${NOW} > ${PERIODIC_THREAD_ENDTIME}

mesg "periodic thread finished"

sleep 3s

svdrpsend.pl hitk back

if [[ "${CAP_SHUTDOWN_SVDRP}" == "1" ]]; then
	svdrpsend.pl DOWN
else
	svdrpsend.pl hitk power
fi

