# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#   Various other contributors from gentoo.de
#

# Input: unix timestamp in variable VDR_WAKEUP_TIME

ACPI_WAKEUP=/usr/sbin/acpi-wakeup.sh

# is acpi in kernel activated?
if [[ ! -f /proc/acpi/alarm ]]; then
	echo error: no acpi installed
fi
if [[ ! -x ${ACPI_WAKEUP} ]]; then
	echo error: no acpi command
	return
fi

${ACPI_WAKEUP} ${VDR_WAKEUP_TIME}
EXITCODE=0
