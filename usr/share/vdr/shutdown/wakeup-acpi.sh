# $Id$
# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#   Various other contributors from gentoo.de
#

ACPI_WAKEUP=/usr/sbin/acpi-wakeup.sh

wakeup_check() {
	local msg
	if [ ! -x "${ACPI_WAKEUP}" ]; then
		error_mesg "acpi-wakeup.sh not found"
		return 1
	fi

	msg=$(${ACPI_WAKEUP} check)
	if [ $? != 0 ]; then
		error_mesg "${msg}"
		return 1
	fi
	return 0
}

wakeup_set() {
	${ACPI_WAKEUP} ${1}
}
