if [[ "${VDR_USERSHUTDOWN}" == "0" && "${AUTOMATIC_SHUTDOWN:-yes}" == "no" ]]; then
	shutdown_abort "automatic shutdown disabled"
	EXITCODE=1
fi
