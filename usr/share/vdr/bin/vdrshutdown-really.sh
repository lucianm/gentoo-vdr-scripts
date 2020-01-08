#!/bin/sh
#
# Author:
#	Matthias Schwarzott <zzam@gmx.de>
#	Joerg Bornkessel <hd_brummy@gentoo.org>
#	Various other contributors from gentoo.de
#
# some ideas from ctvdr's shutdownvdr by Tobias Grimm <tg@e-tobi.net>
#

# This script is called by vdr when triggering shutdown
# called from vdr with: vdr -s vdrshutdown-gate.sh

# It calls all shell-scripts located under /usr/share/vdr/shutdown
# for checking if shutdown should be allowed.
# A lot of functions defined in here can be used
# from within these scripts.

#fork to background already done by vdrshutdown-gate.sh for now
#if [ -z "${EXECUTED_BY_VDR_BG}" ]; then
#	exec /usr/share/vdr/bin/vdr-bg.sh "${0}" "${@}"
#	exit
#fi

if [ "$(id  -u)" != "0" ]; then
	echo "This program should be run as root"
	exit 99
fi

# should be default paths on a machine build with vdr ebuilds
NVRAM_WAKEUP=/usr/bin/nvram-wakeup
HOOKDIR=/usr/share/vdr/shutdown

. /usr/share/vdr/inc/functions.sh
include shutdown-functions
read_caps

include svdrpcmd
svdrp_command

VDR_TIMER_NEXT="${1}"
VDR_TIMER_DELTA="${2}"
VDR_TIMER_CHANNEL="${3}"
VDR_TIMER_FILENAME="${4}"
VDR_USERSHUTDOWN="${5}"

# include this to override the default shutdown_default_retry_time
. /etc/conf.d/vdr.shutdown
: ${SHUTDOWN_DEFAULT_RETRY_TIME:=5}

if [ "${DEBUG}" -ge 1 ]; then
	exec </dev/null >/tmp/vdrshutdown-really.log 2>&1
	echo Started debug output of $0 $@
	nr=0
	for f; do
		nr=$(($nr+1))
		echo "param #${nr} - ${f}"
	done
	set -x
fi

svdrp_send() {
	${SVDRPCMD} "$@"
	logger -t mesg -p user.warn "$*"
}

mesg() {
	svdrp_send MESG ${1}
}

is_auto_shutdown() {
	[ "${VDR_USERSHUTDOWN}" = "0" ]
}

is_user_shutdown() {
	[ "${VDR_USERSHUTDOWN}" = "1" ]
}

is_forced_shutdown() {
	[ "${THIS_SHUTDOWN_IS_FORCED}" = "1" ]
}

is_shutdown_aborted() {
	[ "${SHUTDOWN_ABORT}" = "1" ]
}

forced_tests_count_greater_zero() {
	[ "${SHUTDOWN_FORCE_COUNT}" -gt 0 ]
}

set_retry_time() {
	local TIME="${1}"
	if [ "${TRY_AGAIN}" -lt "${TIME}" ]; then
		TRY_AGAIN=${TIME}
	fi
}

shutdown_abort_common() {
	ABORT_MESSAGE="${1}"
	SHUTDOWN_ABORT="1"
	set_retry_time "${SHUTDOWN_DEFAULT_RETRY_TIME}"
}

shutdown_abort() {
	shutdown_abort_common "${1}"
	disable_forced_shutdown
}

shutdown_abort_can_force() {
	if is_forced_shutdown; then
		# this is the forced way, ignore this abort
		echo FORCED: ${1}
		SHUTDOWN_FORCE_COUNT=$(($SHUTDOWN_FORCE_COUNT+1))
	else
		shutdown_abort_common "${1}"
	fi
}

shutdown_abort_exit() {
	local ABORT_MESSAGE="${1}"
	local EXITCODE=1

	mesg "Shutdown aborted: ${ABORT_MESSAGE}"
	exit ${EXITCODE}
}



init_forced_shutdown() {
	SHUTDOWN_CAN_FORCE=0
	THIS_SHUTDOWN_IS_FORCED="0"

	# only continue if user-shutdown
	if ! is_user_shutdown; then
		return 0
	fi



	# detect if this could be a forced shutdown
	local shutdown_force_file=${shutdown_data_dir}/last-shutdown-abort

	local LAST_SHUTDOWN_ABORT=$(read_int_from_file "${shutdown_force_file}")
	NOW=$(date +%s)
	local DISTANCE=$(($NOW-$LAST_SHUTDOWN_ABORT))
	if [ "${DISTANCE}" -lt "${SHUTDOWN_FORCE_DETECT_INTERVALL:-60}" ]; then
		THIS_SHUTDOWN_IS_FORCED="1"
	fi

	[ -f "${shutdown_force_file}" ] && rm "${shutdown_force_file}"
	SHUTDOWN_FORCE_COUNT=0
	SHUTDOWN_CAN_FORCE=1
}

disable_forced_shutdown() {
	SHUTDOWN_CAN_FORCE="0"
}

write_force_file() {
	local shutdown_force_file=${shutdown_data_dir}/last-shutdown-abort
	echo "${NOW}" > "${shutdown_force_file}"
}

check_forced_shutdown_possible_next_time() {
	if [ "${SHUTDOWN_CAN_FORCE}" = "1" ]; then
		write_force_file
		sleep 1s
		mesg "You can force a shutdown with pressing power again"
	fi
}

execute_hooks() {
	local HOOK
	for HOOK in $HOOKDIR/pre-shutdown-*.sh; do
		[ -r "${HOOK}" ] || continue
		sh -n "${HOOK}" || continue
		. "${HOOK}"
	done
}

retry_shutdown() {
	local when=${TRY_AGAIN}

	if [ -n "${CAP_SHUTDOWN_SVDRP}" ]; then
		if [ "${when}" -gt 5 ]; then
			svdrp_send "DOWN $(($when-5))"
		else
			svdrp_send "DOWN"
		fi
		return
	fi

	if [ "${CAP_SHUTDOWN_AUTO_RETRY:-0}" = "1" ]; then
		# vdr itself will retry shutdown in a reasonable time
		return
	fi
	
	# shutdown retry must be simulated by sleep and the power key
	#as vdr itself is not able

	# just do it here without forking as we are already in background wrt vdr
	sleep ${when}m
	svdrp_send "hitk power"
}

check_auto_retry() {
	if [ "${TRY_AGAIN}" -gt 0 -a "${ENABLE_AUTO_RETRY}" = 1 ]; then
		retry_shutdown ${TRY_AGAIN}
	fi
}

disable_auto_retry() {
	ENABLE_AUTO_RETRY=0
}

init() {
	SHUTDOWN_ABORT=0
	TRY_AGAIN=0
	ENABLE_AUTO_RETRY=1
}


init
init_forced_shutdown
execute_hooks

if is_shutdown_aborted; then
	mesg "No Shutdown: ${ABORT_MESSAGE}"
	check_forced_shutdown_possible_next_time
	check_auto_retry

	exit 0
fi


# TODO: Integrate code into here (+rewrite)
# Keep VDR_TIMER_NEXT here, instead of $@, as it could have been changed
/usr/share/vdr/bin/vdrshutdown-wakeup-helper.sh "${VDR_TIMER_NEXT}"

if [ $? != 0 ]; then
	mesg "setting wakeup time not successful"
	exit 1
fi

rm "${shutdown_data_dir}/shutdown-time-written"
date +%s > "${shutdown_data_dir}/shutdown-time-written"

if is_forced_shutdown && forced_tests_count_greater_zero; then
	mesg "User enforced shutdown"
else
	mesg "Shutting down"
fi

exit 0
