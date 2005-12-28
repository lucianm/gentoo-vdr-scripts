source /etc/conf.d/vdr.shutdown.epgscan

: ${VDR_SHUTDOWN_EPGSCAN:=no}
: ${VDR_SHUTDOWN_EPGSCAN_TIME:=10}

if [[ ${VDR_SHUTDOWN_EPGSCAN} == "yes" ]]; then
	/usr/bin/svdrpsend.pl SCAN
	sleep ${VDR_SHUTDOWN_EPGSCAN_TIME}m
fi

