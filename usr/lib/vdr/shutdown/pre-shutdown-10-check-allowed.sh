if [[ "${VDR_USERSHUTDOWN}" == "0" && "${AUTOMATIC_SHUTDOWN:-yes}" == "no" ]]; then
	ABORT_MESSAGE="automatic shutdown disabled"
	EXITCODE=1
fi
