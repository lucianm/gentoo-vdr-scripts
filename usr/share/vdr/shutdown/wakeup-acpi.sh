# $Id$
# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#   Various other contributors from gentoo.de
#

ACPI_WAKEUP=/usr/sbin/acpi-wakeup.sh

wakeup_check() {
	# is acpi in kernel activated?
	if [ ! -f /proc/acpi/alarm ]; then
		error_mesg "No acpi-driver installed, /proc/acpi/alarm does not exist!"
		return 1
	fi
	if [ ! -x "${ACPI_WAKEUP}" ]; then
		error_mesg "acpi-wakeup.sh not found"
		return 1
	fi
	return 0
}

wakeup_set() {
	${ACPI_WAKEUP} ${1}
}
