check_logins() {
	local NR=$(who | wc -l)
	if [[ "${NR}" -gt "0" ]]; then
		shutdown_abort_can_force "${NR} user(s) are logged in"
	fi
}

if [[ "${VDR_CHECK_LOGINS:-yes}" == "yes" ]]; then
	check_logins
fi
