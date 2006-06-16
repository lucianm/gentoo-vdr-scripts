# $Id$
# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#   Various other contributors from gentoo.de
#

ACPI_WAKEUP=/usr/sbin/acpi-wakeup.sh

# is acpi in kernel activated?
if [[ ! -f /proc/acpi/alarm ]]; then
	error_mesg "No acpi-driver installed, /proc/acpi/alarm does not exist!"
	SHUTDOWN_EXITCODE=1
	return
fi
if [[ ! -x ${ACPI_WAKEUP} ]]; then
	error_mesg "acpi-wakeup.sh not found"
	SHUTDOWN_EXITCODE=1
	return
fi

set_wakeup() {
	${ACPI_WAKEUP} ${1}
	SHUTDOWN_EXITCODE=$?
}
