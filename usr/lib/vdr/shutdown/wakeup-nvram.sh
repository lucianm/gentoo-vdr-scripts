# $Id$
# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#   Various other contributors from gentoo.de
#

NVRAM_WAKEUP=/usr/bin/nvram-wakeup


if [[ ! -x ${NVRAM_WAKEUP} ]]; then
	error_mesg "no nvram-wakeup installed"
	SHUTDOWN_EXITCODE=1
fi

set_wakeup() {
	local CMD="${NVRAM_WAKEUP} --syslog"

	[[ -n "${NVRAM_CONFIG}" ]] && CMD="${CMD} -C ${NVRAM_CONFIG}"

	[[ -n "${NVRAM_EXTRA_OPTIONS}" ]] && CMD="${CMD} ${NVRAM_EXTRA_OPTIONS}"

	CMD="${CMD} -s ${VDR_WAKEUP_TIME}"

	${CMD}

	# analyse
	case $PIPESTATUS in
		0) 
		# all went ok
		SHUTDOWN_EXITCODE=0
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
		SHUTDOWN_EXITCODE=0
		set_reboot_needed
		;;

		2) 
		# something went wrong
		# don't do anything - just exit with status 1
		SHUTDOWN_EXITCODE=1

		error_mesg "Something went wrong, please check your config files of nvram-wakeup"
		;;
	esac
}
