# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#   Various other contributors from gentoo.de
#

# Input: unix timestamp in variable VDR_WAKEUP_TIME

NVRAM_WAKEUP=/usr/bin/nvram-wakeup


if [[ ! -x ${NVRAM_WAKEUP} ]]; then
	echo error: no nvram
	return
fi

CMD="${NVRAM_WAKEUP} --syslog"

[[ -n "${NVRAM_CONFIG}" ]] && CMD="${CMD} -C ${NVRAM_CONFIG}"

CMD="${CMD} -s ${VDR_WAKEUP_TIME}"

${CMD}

# analyse
case $PIPESTATUS in
	0) 
	# all went ok
	EXITCODE=0
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
	EXITCODE=0
	NEED_REBOOT=1
	;;

	2) 
	# something went wrong
	# don't do anything - just exit with status 1
	EXITCODE=1

	echo "Something went wrong, please check your config files of nvram-wakeup"
	;;
esac
