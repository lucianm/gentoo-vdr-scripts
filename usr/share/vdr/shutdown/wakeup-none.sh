# $Id: wakeup-acpi.sh 370 2007-01-04 23:15:45Z zzam $
# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#   Various other contributors from gentoo.de
#

ACPI_WAKEUP=/usr/sbin/acpi-wakeup.sh

wakeup_check() {
	# always works
	return 0
}

wakeup_set() {
	if [ "${1}" != 0 ]; then
		# it is not possible to wakeup the system!
		if [ "${NONE_WAKEUP_IGNORE_TIMER:-no}" = "yes" ]; then
			# ignoring set timers
			:
		else
			# Aborting
			error_mesg "You have some timer set. System will not wakeup on its own!"
			return 1
		fi
	fi

	return 0
}
