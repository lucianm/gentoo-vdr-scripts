addon_main() {
	local FILES="/var/log/vdr.log /var/log/vdr/current /var/log/everything/current /var/log/messages"

	SYSLOG_FILE=""
	local s
	for s in ${FILES}; do
		if [ -f "${s}" ]; then
			SYSLOG_FILE="${s}"

			# Get size of file before vdr start
			SYSLOG_SIZE_BEFORE="$(stat -c %s "${SYSLOG_FILE}")"
			if [ -z "${SYSLOG_SIZE_BEFORE}" ]; then
				# disable syslog-scanning
				SYSLOG_FILE=""
			fi
			return 0
		fi
	done
	return 0
}

