# $Id$
. /etc/conf.d/vdr.periodic.epgscan

: ${PERIODIC_EPGSCAN:=no}
: ${PERIODIC_EPGSCAN_DURATION:=10}

if yesno "${PERIODIC_EPGSCAN}"; then
	/usr/bin/svdrpsend.pl SCAN
	sleep ${PERIODIC_EPGSCAN_DURATION}m
fi

