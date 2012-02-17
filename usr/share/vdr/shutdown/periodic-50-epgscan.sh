# $Id$
. /etc/conf.d/vdr.periodic.epgscan

include svdrpcmd
svdrp_command

: ${PERIODIC_EPGSCAN:=no}
: ${PERIODIC_EPGSCAN_DURATION:=10}

if yesno "${PERIODIC_EPGSCAN}"; then
	${SVDRPCMD} SCAN
	sleep ${PERIODIC_EPGSCAN_DURATION}m
fi
