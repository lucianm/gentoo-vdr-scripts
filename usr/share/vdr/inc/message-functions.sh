# $Id$

#
# Used to log error-messages in startscript to show them on
# OSD later when choosing apropriate point in commands.
#

VDR_LOG_FILE=""

init_vdr_start_log()
{
	VDR_LOG_FILE=/var/vdr/vdr-start-log
	echo "Startlog for VDR" > ${VDR_LOG_FILE}
	LOG_MSG_COUNT=0
	LOG_ERROR_COUNT=0
}

finish_vdr_start_log()
{
	# wenn nachrichten vorhanden sind
	if [[ ${LOG_ERROR_COUNT} = 0 ]]; then
		vdr_log_generic "NO problems at start."
	else
		/usr/share/vdr/bin/vdr-bg.sh svdrpsend.pl mesg "Errors: View via Commands / View VDR Start Log"
	fi
	VDR_LOG_FILE=""
}

vdr_log_generic()
{
	[[ -n ${VDR_LOG_FILE} ]] || return
	
	echo "$@" >> ${VDR_LOG_FILE}
	: $((LOG_MSG_COUNT++))
}
	
	
vdr_einfo()
{
	einfo "$@"
	vdr_log_generic "I: $@"
}

vdr_ewarn()
{
	ewarn "$@"
	vdr_log_generic "W: $@"
}

vdr_eerror()
{
	eerror "$@"
	vdr_log_generic "E: $@"
	: $((LOG_ERROR_COUNT++))
}

