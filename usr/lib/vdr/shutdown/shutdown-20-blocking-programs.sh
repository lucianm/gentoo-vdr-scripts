SHUTDOWN_CHECK_PROGRAMS="make gcc noad cc1 transcode vcdimager mencoder tosvcd lame vdrsync.pl tcmplex"
SHUTDOWN_CHECK_PROGRAMS="${SHUTDOWN_CHECK_PROGRAMS} tcmplex-panteltje vdr2ac3.sh"

PIDOF=pidof
for PROG in ${SHUTDOWN_CHECK_PROGRAMS} ${SHUTDOWN_CHECK_ADDITIONAL_PROGRAMS}; do
	if ${PIDOF} -x ${PROG} >/dev/null; then
		# retry in 10 minutes
		TRY_AGAIN=10
		TRY_AGAIN_MESSAGE="${PROG} is running"
	fi
fi
