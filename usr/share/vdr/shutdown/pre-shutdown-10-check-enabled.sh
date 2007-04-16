# $Id$
if is_auto_shutdown && [ "${AUTOMATIC_SHUTDOWN:-yes}" = "no" ]; then
	shutdown_abort_exit "automatic shutdown disabled"
fi
