
if is_auto_shutdown && ! yesno "${AUTOMATIC_SHUTDOWN:-yes}"; then
	shutdown_abort_exit "automatic shutdown disabled"
fi
