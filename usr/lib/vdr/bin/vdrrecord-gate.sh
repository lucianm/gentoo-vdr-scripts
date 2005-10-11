#!/bin/bash
# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#
SVDRPCMD=/usr/bin/svdrpsend.pl
HOOKDIR=/usr/lib/vdr/record

mesg() {
	${SVDRPCMD} MESG "\"$@\""
}

VDR_RECORD_STATE="${1}"
VDR_RECORD_NAME="${2}"

for HOOK in $HOOKDIR/record-*.sh; do
	[[ -f "${HOOK}" ]] && source "${HOOK}" "${VDR_RECORD_STATE}" "${VDR_RECORD_NAME}"
done
