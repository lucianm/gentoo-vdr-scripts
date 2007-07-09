addon_main() {
	# simulate an error
	#logger "DUMMY-ERROR: /usr/lib/vdr/plugins/libvdr-softdevice.so.1.5.5: undefined symbol: _Z14pp_postprocessPPhPiS0_S1_iiPaiPvS3_i"

	# Abort if we did not find a syslog file
	[ ! -e "${SYSLOG_FILE}" ] && return 0

	#einfo Checking for errors in syslog
	local line
	local count=0

	sed "${SYSLOG_LINES}"',$!d
		/ERROR/!d
		/unknown config parameter:/d
		/ERROR.*lib\/vdr\/plugins/ { s/^.*ERROR:.*\/plugins\//Error loading plugin / }
		' "${SYSLOG_FILE}" \
	| while read line; do
		count=$(($count+1))
		if [ "${count}" -gt 5 ]; then
			eerror "    More errors ... (see ${SYSLOG_FILE})"
			break
		fi
		eerror "    $line"
	done

	return 0
}

