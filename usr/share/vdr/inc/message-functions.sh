# $Id$

#
# Used to log error-messages in startscript to show them on
# OSD later when choosing apropriate point in commands.
#

VDR_LOG_FILE=/var/vdr/tmp/vdr-start-log

init_vdr_start_log()
{
	rm -f "${VDR_LOG_FILE}"
	> "${VDR_LOG_FILE}"
}

finish_vdr_start_log()
{
	# wenn nachrichten vorhanden sind
	if [ -s "${VDR_LOG_FILE}" ]; then
		/usr/share/vdr/bin/vdr-bg.sh svdrpsend.pl mesg "Errors: Go to Commands/View VDR Start Log"
	fi
}

vdr_log()
{
	echo "$@" >> ${VDR_LOG_FILE}
}

