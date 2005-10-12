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
	${SVDRPCMD} MESG "\"$@\""
}

bg_retry() {
	exec >/dev/null 2>/dev/null </dev/null
	sleep ${1}m
	${SVDRPCMD} hitk power
}

EXITCODE=0
MAX_TRY_AGAIN=0
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

if [ ${MAX_TRY_AGAIN} -gt 0 ]; then
	if [[ "${CAP_SHUTDOWN_AUTO_RETRY:-0}" == "1" ]]; then
		#shutdown will be retried automatically by vdr
		:
	else
		# shutdown retry must be simulated by sleep and the power key
		bg_retry ${MAX_TRY_AGAIN} &
	fi
	if [[ -n "${TRY_AGAIN_MESSAGE}" ]]; then
		mesg "Waiting ${MAX_TRY_AGAIN}min to shutdown, because ${TRY_AGAIN_MESSAGE}" &
	else
		mesg "Retrying shutdown in ${MAX_TRY_AGAIN} minutes" &
	fi
	exit 0
fi

# You have to edit sudo-permissions to grant vdr permission to execute
# privileged commands. Start visudo and add a line like
#   vdr     ALL= NOPASSWD: /usr/lib/vdr/bin/vdrshutdown-really.sh

#mesg "Dummy - Real shutdown not working" &

SUDO=/usr/bin/sudo
${SUDO} /usr/lib/vdr/bin/vdrshutdown-really.sh ${VDR_TIMER_NEXT}
