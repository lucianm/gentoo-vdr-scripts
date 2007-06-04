# $Id$

#
# Used to log error-messages in startscript to show them on
# OSD later when choosing apropriate point in commands.
#

VDR_LOG_FILE=""

init_vdr_start_log()
{
	[ -e /var/vdr/vdr-start-log ] && rm -f /var/vdr/vdr-start-log
	VDR_LOG_FILE=/var/vdr/tmp/vdr-start-log
	> "${VDR_LOG_FILE}"
	LOG_MSG_COUNT=0
}

finish_vdr_start_log()
{
	# wenn nachrichten vorhanden sind
	if [ "${LOG_MSG_COUNT}" = 0 ]; then
		vdr_log "NO problems at start."
	else
		/usr/share/vdr/bin/vdr-bg.sh svdrpsend.pl mesg "Errors: Go to Commands/View VDR Start Log"
	fi
	VDR_LOG_FILE=""
}

vdr_log()
{
	[ -n "${VDR_LOG_FILE}" ] || return
	
	echo "$@" >> ${VDR_LOG_FILE}
	LOG_MSG_COUNT=$(($LOG_MSG_COUNT+1))
}

