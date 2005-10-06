#!/bin/bash
# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#
SVDRPCMD=/usr/bin/svdrpsend.pl
HOOKDIR=/usr/lib/vdr/record

mesg() {
	${SVDRPCMD} MESG "\"$@\""
}

for HOOK in $HOOKDIR/record-*.sh; do
	[[ -f "${HOOK}" ]] && source "${HOOK}" "$@"
done
