# $Id$
addon_main() {
	if [ "${FORCE_OLD_THREADS:-yes}" = "yes" ]; then
		# Test wheather force of old pthreads will work
		if LD_ASSUME_KERNEL=2.4.1 /bin/true 2>/dev/null; then
			export LD_ASSUME_KERNEL=2.4.1
			debug_msg "Forcing NPTL off"
		fi
	fi
	return 0
}

