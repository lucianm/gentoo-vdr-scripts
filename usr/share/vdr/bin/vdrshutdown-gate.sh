#!/bin/bash
# $Id$
# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#   Various other contributors from gentoo.de
#
# some ideas from ctvdr's shutdownvdr by Tobias Grimm <tg@e-tobi.net>
#

#fork to background
if [[ -z ${EXECUTED_BY_VDR_BG} ]]; then
	exec /usr/share/vdr/bin/vdr-bg.sh "${0}" "${@}"
	exit
fi

if [[ ${DEBUG} -ge 1 ]]; then
	exec </dev/null >/var/vdr/shutdown-data/log 2>&1
	echo Started debug output of $0 $@
	nr=0
	for f; do
		: $((nr++))
		echo "param #${nr} - ${f}"
	done
	set -x
fi

# should be default paths on a machine build with vdr ebuilds
SVDRPCMD=/usr/bin/svdrpsend.pl
NVRAM_WAKEUP=/usr/bin/nvram-wakeup
HOOKDIR=/usr/share/vdr/shutdown

source /usr/share/vdr/inc/functions.sh
include shutdown-functions

read_caps

VDR_TIMER_NEXT="${1}"
VDR_TIMER_DELTA="${2}"
VDR_TIMER_CHANNEL="${3}"
VDR_TIMER_FILENAME="${4}"
VDR_USERSHUTDOWN="${5}"

: ${SHUTDOWN_DEFAULT_RETRY_TIME:=10}


queue_add_wait() {
	: ${qindex:=1}
	svdrpqueue[${qindex}]="sleep ${1}"
	qindex=$((qindex+1))
}

svdrp_add_queue() {
	: ${qindex:=1}
	logger "vdrshutdown-gate sending per svdrp: ${1}"
	svdrpqueue[${qindex}]="${SVDRPCMD} ${1}"
	qindex=$((qindex+1))
}

svdrp_queue_handler() {
	for ((i=1; i < qindex ; i++))
	do
		# retry until success
		while ! ${svdrpqueue[$i]}; do
			sleep 1
		done
	done
}

mesg() {
	${SVDRPCMD} MESG ${1}
}

mesg_q() {
	svdrp_add_queue "MESG ${1}"
}

retry_shutdown() {
	local when=${MAX_TRY_AGAIN}

	if [[ -n "${CAP_SHUTDOWN_SVDRP}" ]]; then
		if [[ ${when} -gt 5 ]]; then
			svdrp_add_queue "DOWN $((when-5))"
		else
			svdrp_add_queue "DOWN"
		fi
		return
	fi

	if [[ "${CAP_SHUTDOWN_AUTO_RETRY:-0}" == "1" ]]; then
		return
	fi
	
	# shutdown retry must be simulated by sleep and the power key
	#as vdr itself is not able
	queue_add_wait ${when}m
	svdrp_add_queue "hitk power"
	return
}
															
is_auto_shutdown() {
	test "${VDR_USERSHUTDOWN}" == "0"
}

is_user_shutdown() {
	test "${VDR_USERSHUTDOWN}" == "1"
}

is_forced_shutdown() {
	test "${THIS_SHUTDOWN_IS_FORCED}" == "1"
}

shutdown_common() {
	ABORT_MESSAGE="${1}"
	SHUTDOWN_ABORT="1"
	TRY_AGAIN="${SHUTDOWN_DEFAULT_RETRY_TIME}"
}

shutdown_abort() {
	shutdown_common "${1}"
	SHUTDOWN_CAN_FORCE="0"
}

shutdown_abort_can_force() {
	if [[ "${THIS_SHUTDOWN_IS_FORCED}" == "1" ]]; then
		# this is the forced way, ignore this abort
		echo FORCED: ${1}
		FORCE_COUNT=$[FORCE_COUNT+1]
	else
		shutdown_common "${1}"
	fi
}

init_shutdown_force() {
	# detect if this could be a forced shutdown
	local shutdown_force_file=${shutdown_data_dir}/last-shutdown-abort

	local LAST_SHUTDOWN_ABORT=0
	if [[ -f "${shutdown_force_file}" ]]; then
		LAST_SHUTDOWN_ABORT=$(cat "${shutdown_force_file}")
	fi
	NOW=$(date +%s)
	local DISTANCE=$[NOW-LAST_SHUTDOWN_ABORT]
	if [[ "${DISTANCE}" -lt "${SHUTDOWN_FORCE_DETECT_INTERVALL}" ]]; then
		THIS_SHUTDOWN_IS_FORCED="1"
	fi

	[[ -f "${shutdown_force_file}" ]] && rm "${shutdown_force_file}"
	FORCE_COUNT=0
	SHUTDOWN_CAN_FORCE=1
}

write_force_file() {
	local shutdown_force_file=${shutdown_data_dir}/last-shutdown-abort
	echo "${NOW}" > "${shutdown_force_file}"
}

exit_cleanup()
{
	svdrp_queue_handler &
	exit ${1}
}

THIS_SHUTDOWN_IS_FORCED="0"
EXITCODE="-"
SHUTDOWN_ABORT=0
SHUTDOWN_CAN_FORCE=0
MAX_TRY_AGAIN=0
ENABLE_AUTO_RETRY=1

disable_auto_retry() {
	ENABLE_AUTO_RETRY=0
}

if is_user_shutdown; then
	init_shutdown_force
fi

for HOOK in $HOOKDIR/pre-shutdown-*.sh; do
	TRY_AGAIN=0
	[[ -f "${HOOK}" ]] && source "${HOOK}" $@

	if [[ "${EXITCODE}" != "-" ]]; then
		mesg_q "Shutdown aborted: ${ABORT_MESSAGE}"
		exit_cleanup ${EXITCODE} 
	fi

	if [[ ${TRY_AGAIN} -gt 0 ]]; then
		if [[ ${MAX_TRY_AGAIN} -lt ${TRY_AGAIN} ]]; then
			MAX_TRY_AGAIN=${TRY_AGAIN}
		fi
	fi
done

if [[ "${SHUTDOWN_ABORT}" == "1" ]]; then
	mesg_q "Shutdown stopped, because ${ABORT_MESSAGE}"
	if [[ "${SHUTDOWN_CAN_FORCE}" == "1" ]]; then
		write_force_file
		queue_add_wait 1s
		mesg_q "You can force a shutdown with pressing power again"
	fi

	if [[ ${MAX_TRY_AGAIN} -gt 0 && ${ENABLE_AUTO_RETRY} == 1 ]]; then
		queue_add_wait 1s
		mesg_q "Shutdown is retried soon"
		retry_shutdown ${MAX_TRY_AGAIN}
	fi

	exit_cleanup 0
fi

if [[ "${THIS_SHUTDOWN_IS_FORCED}" == "1" && "${FORCE_COUNT}" -gt 0 ]]; then
	mesg_q "Shutting down, shutdown forced by user."
else
	mesg_q "Shutting down now"
fi

# You have to edit sudo-permissions to grant vdr permission to execute
# privileged commands. Start visudo and add a line like
#   vdr     ALL= NOPASSWD: /usr/share/vdr/bin/vdrshutdown-really.sh

#mesg_q "Dummy - Real shutdown not working"


SUDO=/usr/bin/sudo
if [[ -z ${DRY_SHUTDOWN} ]]; then
	if ! ${SUDO} /usr/share/vdr/bin/vdrshutdown-really.sh ${VDR_TIMER_NEXT}; then
		mesg_q "sudo failed"
		mesg_q "call emerge --config gentoo-vdr-scripts"
	fi
else
	logger DRY_SHUTDOWN shutdown, vdrshutdown-really.sh ${VDR_TIMER_NEXT}
fi

date +%s > ${shutdown_data_dir}/shutdown-time-written
exit_cleanup 0
