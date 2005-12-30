#!/bin/bash
source /usr/lib/vdr/rcscript/functions-shutdown.sh
THREAD_DIR=/usr/lib/vdr/shutdown

mesg "periodic thread started"

for HOOK in ${THREAD_DIR}/periodic-*.sh; do
	[[ -f "${HOOK}" ]] && source "${HOOK}"
done
mesg "periodic thread finished"

sleep 3s

if [[ "${CAP_SHUTDOWN_SVDRP}" == "1" ]]; then
	svdrpsend.pl DOWN
else
	svdrpsend.pl hitk power
fi

