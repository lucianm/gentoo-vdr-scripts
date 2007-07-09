addon_main() {
	local FILES="/var/log/everything/current /var/log/messages"

	SYSLOG_FILE=""
	local s
	for s in ${FILES}; do
		if [ -e "${s}" ]; then
			SYSLOG_FILE="${s}"

			# Get number of already existing lines in this file
			SYSLOG_LINES="$(wc -l "${SYSLOG_FILE}")"
			SYSLOG_LINES="${SYSLOG_LINES% *}"
			return 0
		fi
	done
	return 0
}

