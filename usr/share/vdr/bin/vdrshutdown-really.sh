#!/bin/sh
# $Id$
# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#   Various other contributors from gentoo.de
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

if [ "$UID" != "0" ]; then
	echo "This program should be run as root"
	exit 99
fi

# should be default paths on a machine build with vdr ebuilds
SVDRPCMD=/usr/bin/svdrpsend.pl
NVRAM_WAKEUP=/usr/bin/nvram-wakeup
HOOKDIR=/usr/share/vdr/shutdown

. /usr/share/vdr/inc/functions.sh
include shutdown-functions

read_caps

VDR_TIMER_NEXT="${1}"
VDR_TIMER_DELTA="${2}"
VDR_TIMER_CHANNEL="${3}"
VDR_TIMER_FILENAME="${4}"
VDR_USERSHUTDOWN="${5}"

: ${SHUTDOWN_DEFAULT_RETRY_TIME:=10}

if [ "${DEBUG}" -ge 1 ]; then
	exec </dev/null >/tmp/vdrshutdown-gate-log 2>&1
	echo Started debug output of $0 $@
	nr=0
	for f; do
		nr=$(($nr+1))
		echo "param #${nr} - ${f}"
	done
	set -x
fi


queue_add_wait() {
	: ${qindex:=1}
	eval svdrpqueue_${qindex}="\"sleep $1\""
	qindex=$(($qindex+1))
}

svdrp_add_queue() {
	: ${qindex:=1}
	logger "vdrshutdown-gate sending per svdrp: $1"
	eval svdrpqueue_${qindex}="\"${SVDRPCMD} $1\""
	qindex=$(($qindex+1))
}

svdrp_queue_handler() {
	local i=1
	local ITEM
	while [ $i -lt $qindex ]; do
		# retry until success
		eval ITEM=\$svdrpqueue_${i}
		while ! ${ITEM}; do
			sleep 1
		done
		i=$(($i+1))
	done
}

mesg() {
	${SVDRPCMD} MESG ${1}
}

mesg_q() {
	svdrp_add_queue "MESG ${1}"
}

retry_shutdown() {
	local when=${TRY_AGAIN}

	if [ -n "${CAP_SHUTDOWN_SVDRP}" ]; then
		if [ "${when}" -gt 5 ]; then
			svdrp_add_queue "DOWN $(($when-5))"
		else
			svdrp_add_queue "DOWN"
		fi
		return
	fi

	if [ "${CAP_SHUTDOWN_AUTO_RETRY:-0}" = "1" ]; then
		# vdr itself will retry shutdown in a reasonable time
		return
	fi
	
	# shutdown retry must be simulated by sleep and the power key
	#as vdr itself is not able
	queue_add_wait ${when}m
	svdrp_add_queue "hitk power"
	return
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

	mesg_q "Shutdown aborted: ${ABORT_MESSAGE}"
	exit_cleanup ${EXITCODE}
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

	local LAST_SHUTDOWN_ABORT=0
	if [ -f "${shutdown_force_file}" ]; then
		LAST_SHUTDOWN_ABORT=$(cat "${shutdown_force_file}")
	fi
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
		queue_add_wait 1s
		mesg_q "You can force a shutdown with pressing power again"
	fi
}

exit_cleanup() {
	svdrp_queue_handler &
	exit ${1}
}

execute_hooks() {
	local HOOK
	for HOOK in $HOOKDIR/pre-shutdown-*.sh; do
		[ -r "${HOOK}" ] || continue
		sh -n "${HOOK}" || continue
		. "${HOOK}"
	done
}

check_auto_retry() {
	if [ "${TRY_AGAIN}" -gt 0 -a "${ENABLE_AUTO_RETRY}" = 1 ]; then
		queue_add_wait 1s
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
	mesg_q "No Shutdown: ${ABORT_MESSAGE}"
	check_forced_shutdown_possible_next_time
	check_auto_retry
	
	exit_cleanup 0
fi


# TODO: Integrate code into here (+rewrite)
vdrshutdown-wakeup-helper.sh "$@"

if [ $? != 0 ]; then
	mesg_q "setting wakeup time not successful"
	exit_cleanup 1
fi

rm "${shutdown_data_dir}/shutdown-time-written"
date +%s > "${shutdown_data_dir}/shutdown-time-written"

if is_forced_shutdown && forced_tests_count_greater_zero; then
	mesg_q "User enforced shutdown"
else
	mesg_q "Shutting down"
fi

exit_cleanup 0

