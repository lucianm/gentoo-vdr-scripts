# $Id$
# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#   Various other contributors from gentoo.de
#

ACPI_WAKEUP=/usr/sbin/acpi-wakeup.sh

if [ ! -x "${ACPI_WAKEUP}" ]; then
	error_mesg "acpi-wakeup.sh not found"
	return 1
fi

if [ ! -e /proc/acpi/alarm ]; then
	error_mesg "/proc/acpi/alarm does not exist"
	return 1
fi

"${ACPI_WAKEUP}" "${VDR_WAKEUP_TIME}"
