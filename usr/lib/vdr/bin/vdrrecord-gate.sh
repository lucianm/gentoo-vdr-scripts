#!/bin/bash
# $Id$
# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#

#fork to background
if [[ -z ${EXECUTED_BY_VDR_BG} ]]; then
	exec /usr/lib/vdr/bin/vdr-bg.sh "${0}" "${@}"
	exit
fi

SVDRPCMD=/usr/bin/svdrpsend.pl
HOOKDIR=/usr/lib/vdr/record

source /usr/share/vdr/inc/functions.sh

mesg() {
	${SVDRPCMD} MESG "\"$@\""
}

VDR_RECORD_STATE="${1}"
VDR_RECORD_NAME="${2}"

for HOOK in $HOOKDIR/record-*.sh; do
	[[ -f "${HOOK}" ]] && source "${HOOK}" "${VDR_RECORD_STATE}" "${VDR_RECORD_NAME}"
done
