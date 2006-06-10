# $Id$
if is_auto_shutdown && [[ "${AUTOMATIC_SHUTDOWN:-yes}" == "no" ]]; then
	shutdown_abort "automatic shutdown disabled"
	EXITCODE=1
fi
