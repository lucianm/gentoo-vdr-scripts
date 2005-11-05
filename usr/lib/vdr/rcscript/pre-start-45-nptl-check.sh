if [[ "${FORCE_OLD_THREADS:-yes}" == "yes" ]]; then
	# Test wheather force of old pthreads will work
	if LD_ASSUME_KERNEL=2.4.1 /bin/true 2>/dev/null; then
		export LD_ASSUME_KERNEL=2.4.1
		einfo_level2 setting LD_ASSUME_KERNEL=2.4.1
	else
		einfo "vdr: You use a NPTL only system, using nptl and hoping the best."
	fi
fi
