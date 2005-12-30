#!/bin/bash
# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#   Various other contributors from gentoo.de
#
# some ideas from ctvdr's shutdownvdr by Tobias Grimm <tg@e-tobi.net>
#

# should be default paths on a machine build with vdr ebuilds
SVDRPCMD=/usr/bin/svdrpsend.pl
NVRAM_WAKEUP=/usr/bin/nvram-wakeup
HOOKDIR=/usr/lib/vdr/shutdown

source /usr/lib/vdr/rcscript/functions-shutdown.sh
read_shutdown_config

source /usr/lib/vdr/rcscript/vdr-capabilities.sh

VDR_TIMER_NEXT="${1}"
VDR_TIMER_DELTA="${2}"
VDR_TIMER_CHANNEL="${3}"
VDR_TIMER_FILENAME="${4}"
VDR_USERSHUTDOWN="${5}"

mesg() {
	${SVDRPCMD} MESG "${1}"
}

bg_retry() {
	exec >/dev/null 2>/dev/null </dev/null
	sleep ${1}m
	${SVDRPCMD} hitk power
}

retry_shutdown() {
	local when=${MAX_TRY_AGAIN}

	if [[ -n "${CAP_SHUTDOWN_SVDRP}" ]]; then
		${SVDRPCMD} DOWN "${when}"
		return
	fi

	if [[ "${CAP_SHUTDOWN_AUTO_RETRY:-0}" == "1" ]]; then
		return
	fi
	
	# shutdown retry must be simulated by sleep and the power key
	#as vdr itself is not able
	bg_retry ${when} &
	return
}
															
is_auto_shutdown() {
	test "${VDR_USERSHUTDOWN}" == "0"
}

is_user_shutdown() {
	test "${VDR_USERSHUTDOWN}" == "1"
}

shutdown_abort() {
	ABORT_MESSAGE="${1}"
	SHUTDOWN_ABORT="1"
	SHUTDOWN_CAN_FORCE="0"
	if is_auto_shutdown; then
		TRY_AGAIN="10"
	fi
}

shutdown_abort_can_force() {
	if is_auto_shutdown; then
		# normal way, do retry
		shutdown_abort "${1}"
	else
		if [[ "${THIS_SHUTDOWN_IS_FORCED}" == "1" ]]; then
			# this is the forced way, ignore this abort
			echo FORCED: ${1}
			FORCE_COUNT=$[FORCE_COUNT+1]
		else
			ABORT_MESSAGE="${1}"
			SHUTDOWN_ABORT="1"
		fi
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

THIS_SHUTDOWN_IS_FORCED="0"
EXITCODE=0
SHUTDOWN_ABORT=0
SHUTDOWN_CAN_FORCE=0
MAX_TRY_AGAIN=0

if is_user_shutdown; then
	init_shutdown_force
fi

for HOOK in $HOOKDIR/pre-shutdown-*.sh; do
	TRY_AGAIN=0
	[[ -f "${HOOK}" ]] && source "${HOOK}" $@

	if [[ "${EXITCODE}" != "0" ]]; then
		mesg "Shutdown aborted: ${ABORT_MESSAGE}" &
		exit 1
	fi

	if [[ ${TRY_AGAIN} -gt 0 ]]; then
		if [[ ${MAX_TRY_AGAIN} -lt ${TRY_AGAIN} ]]; then
			MAX_TRY_AGAIN=${TRY_AGAIN}
		fi
	fi
done

if [[ "${SHUTDOWN_ABORT}" == "1" ]]; then
	if [[ "${SHUTDOWN_CAN_FORCE}" == "1" ]]; then
		write_force_file
		(
			mesg "Shutdown stopped, because ${ABORT_MESSAGE}"
			sleep 3
			mesg "You can force a shutdown with pressing power again"
		) &
	fi

	if [ ${MAX_TRY_AGAIN} -gt 0 ]; then
		retry_shutdown ${MAX_TRY_AGAIN}
		mesg "Shutdown retries soon, because ${ABORT_MESSAGE}" &
	fi


	exit 0
fi

if [[ "${THIS_SHUTDOWN_IS_FORCED}" == "1" && "${FORCE_COUNT}" -gt 0 ]]; then
	mesg "Shutting down, shutdown forced by user." &
fi

# You have to edit sudo-permissions to grant vdr permission to execute
# privileged commands. Start visudo and add a line like
#   vdr     ALL= NOPASSWD: /usr/lib/vdr/bin/vdrshutdown-really.sh

#mesg "Dummy - Real shutdown not working" &


SUDO=/usr/bin/sudo
${SUDO} /usr/lib/vdr/bin/vdrshutdown-really.sh ${VDR_TIMER_NEXT}

date +%s > ${shutdown_data_dir}/shutdown-time-written

