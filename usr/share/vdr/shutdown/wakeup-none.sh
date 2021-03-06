#
# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#   Various other contributors from gentoo.de
#

if [ "${VDR_WAKEUP_TIME}" != 0 ]; then
	# it is not possible to wakeup the system!
	if yesno "${NONE_WAKEUP_IGNORE_TIMER}"; then
		# ignoring set timers
		:
	else
		# Aborting
		mesg "You have some timer set. System will not wakeup on its own!"
		return 1
	fi
fi

return 0
