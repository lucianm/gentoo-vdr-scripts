# $Id$
source /etc/conf.d/vdr.periodic.epgscan

: ${PERIODIC_EPGSCAN:=no}
: ${PERIODIC_EPGSCAN_DURATION:=10}

if [ ${PERIODIC_EPGSCAN} = "yes" ]; then
	/usr/bin/svdrpsend.pl SCAN
	sleep ${PERIODIC_EPGSCAN_DURATION}m
fi

