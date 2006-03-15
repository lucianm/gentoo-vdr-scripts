# $Id$

init_vdr_log()
{
	VDR_LOG_FILE=/var/vdr/vdr-start-log
	echo "Startlog for VDR" > ${VDR_LOG_FILE}
	LOG_MSG_COUNT=0
	LOG_ERROR_COUNT=0
}

vdr_display_info_about_log()
{
	# wenn nachrichten vorhanden sind
	if [[ 0 -lt ${LOG_ERROR_COUNT} ]]; then
		/usr/lib/vdr/bin/vdr-bg.sh svdrpsend.pl mesg "Errors: View via Commands / View VDR Start Log"
	fi
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
	vdr_log_generic "I: $@" >> ${VDR_LOG_FILE}
}

vdr_ewarn()
{
	ewarn "$@"
	vdr_log_generic "W: $@" >> ${VDR_LOG_FILE}
}

vdr_eerror()
{
	eerror "$@"
	vdr_log_generic "E: $@" >> ${VDR_LOG_FILE}
	: $((LOG_ERROR_COUNT++))
}


init_vdr_log

