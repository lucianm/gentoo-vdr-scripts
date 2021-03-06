
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
	dd if="${SYSLOG_FILE}" ibs="${SYSLOG_SIZE_BEFORE}" skip=1 obs=1024 2>/dev/null \
	| sed '/vdr.*ERROR/!d
		s/^.* ERROR: /ERROR: /
		/unknown config parameter:/d
		s#ERROR: "$(pkg-config --variable=libdir vdr)"/#ERROR: loading plugin #
		' \
	| while read line; do
		count=$(($count+1))
		if [ ${count} -eq 1 ]; then
			eerror "VDR errors from ${SYSLOG_FILE}:"
		fi
		eerror "  $line"
		if [ "${count}" -gt 5 ]; then
			eerror "More errors ..."
			break
		fi
	done

	return 0
}
