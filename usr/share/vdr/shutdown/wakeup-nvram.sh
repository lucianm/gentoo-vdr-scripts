# $Id$
# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#   Various other contributors from gentoo.de
#

NVRAM_WAKEUP=/usr/bin/nvram-wakeup

wakeup_check() {
	if [ ! -x "${NVRAM_WAKEUP}" ]; then
		error_mesg "no nvram-wakeup installed"
		return 1
	fi

	return 0
}

wakeup_set() {
	local CMD="${NVRAM_WAKEUP} --syslog"

	[ -n "${NVRAM_CONFIG}" ] && CMD="${CMD} -C ${NVRAM_CONFIG}"

	[ -n "${NVRAM_EXTRA_OPTIONS}" ] && CMD="${CMD} ${NVRAM_EXTRA_OPTIONS}"

	CMD="${CMD} -s ${1}"

	${CMD}

	# analyse
	case $PIPESTATUS in
		0) 
		# all went ok
		return 0
		;;
		
		1) 
		# all went ok - new date and time set.
		#
		# *** but we need to reboot. ***
		#
		# for some boards this is needed after every change.
		#
		# for some other boards, we only need this after changing the
		# status flag, i.e. from enabled to disabled or the other way.
		set_reboot_needed
		return 0
		;;

		2) 
		# something went wrong

		error_mesg "Something went wrong, please check your config files of nvram-wakeup"
		# don't do anything - just exit with status 1
		return 1
		;;
		*)
		# should not happen anyway.

		error_mesg "Something went wrong, should never happen"
		return 1
		;;
	esac
}
