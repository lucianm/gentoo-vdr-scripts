
# Baselayout 2
. /etc/conf.d/hwclock

do_systohc() {
	hwclock --systohc
}

if yesno "${SHUTDOWN_SYSTOHC:-no}"; then
	if [ ${CLOCK_SYSTOHC:=no} == "no" ] || [ ${clock_systohc:=NO} == "NO" ] ; then
		do_systohc
	fi
fi
