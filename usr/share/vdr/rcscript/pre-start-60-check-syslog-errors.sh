
addon_main() {
	yesno "${CHECK_SYSLOG_ERRORS:-yes}" || return 0

	local s FILES="/var/log/vdr.log /var/log/vdr/current /var/log/everything/current /var/log/messages"

	SYSLOG_FILE=""
	for s in ${FILES}; do
		if [ -f "${s}" ]; then
			SYSLOG_FILE="${s}"
			break
		fi
	done

	# found a file?
	[ -z "${SYSLOG_FILE}" ] && return 0

	# Get size of file before vdr start
	SYSLOG_SIZE_BEFORE="$(stat -c %s "${SYSLOG_FILE}")"
	if [ -z "${SYSLOG_SIZE_BEFORE}" ]; then
		# disable syslog-scanning
		SYSLOG_FILE=""
	fi
	return 0
}
