
simulate_syslog_errors() {
	# Inject some errors to test the code
	logger -t vdr "DUMMY ERROR: /usr/lib/vdr/plugins/libvdr-softdevice.so.1.5.5: undefined symbol: _Z14pp_postprocessPPhPiS0_S1_iiPaiPvS3_i"
	logger -t vdr "ERROR: unknown plugin 'director'"
	logger -t vdr "ERROR: empty key macro"
	logger -t vdr "ERROR: source base /net/gauss/home/audio not found"
	logger -t vdr "ERROR: source base /mnt/usbstick not found"
}

addon_main() {
	# Abort if we did not find a syslog file
	[ ! -e "${SYSLOG_FILE}" ] && return 0

	# simulate errors
	#simulate_syslog_errors

	#einfo Checking for errors in syslog
	local line
	local count=0

	# extract relevant error lines out of syslog, and show up to 5 of them
	sed "${SYSLOG_LINES}"',$!d
		/vdr.*ERROR/!d
		s/^.* ERROR: /ERROR: /
		/unknown config parameter:/d
		s#ERROR: /usr/lib/vdr/plugins/#ERROR: loading plugin #
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

