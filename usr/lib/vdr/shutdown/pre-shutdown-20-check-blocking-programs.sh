SHUTDOWN_CHECK_PROGRAMS="emerge make gcc noad cc1 transcode vcdimager mencoder tosvcd lame vdrsync.pl tcmplex"
SHUTDOWN_CHECK_PROGRAMS="${SHUTDOWN_CHECK_PROGRAMS} tcmplex-panteltje vdr2ac3.sh dvdauthor"

PIDOF=pidof
for PROG in ${SHUTDOWN_CHECK_PROGRAMS} ${SHUTDOWN_CHECK_ADDITIONAL_PROGRAMS}; do
	if ${PIDOF} -x ${PROG} >/dev/null; then
		# stop shutdown
		shutdown_abort_can_force "${PROG} is running"
		break
	fi
done
