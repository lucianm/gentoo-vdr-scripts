# $Id$

if [ ! -f /etc/init.d/sysfs ]; then
# Baselayout 1
. /etc/conf.d/clock
    else
# Baselayout 2
. /etc/conf.d/hwclock
fi


do_systohc() {
    hwclock --systohc
}

if yesno "${SHUTDOWN_SYSTOHC:-no}"; then

    if [ ${CLOCK_SYSTOHC:=no} == "no" ] || [ ${clock_systohc:=NO} == "NO" ] ;then

        do_systohc

    fi

fi
