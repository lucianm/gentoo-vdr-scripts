#!/bin/sh
# $Id$
# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#

#
# This script is called from vdrshutdown-gate.sh over sudo to
# have root-permissions for setting wakeup-time and triggering
# real shutdown/reboot.
#

if [ "$(id -u)" != "0" ]; then
	echo "This program should be run as root"
	exit 99
fi

. /usr/share/vdr/inc/functions.sh
include shutdown-functions
shutdown_script_dir=/usr/share/vdr/shutdown
SVDRPCMD=/usr/bin/svdrpsend.pl

if [ "${DEBUG}" -ge 1 ]; then
	exec >/tmp/vdrshutdown-wakeup-helper.log 2>&1
	echo Started debug output of $0 $@
	set -x
fi

VDR_WAKEUP_TIME="${1}"

mesg() {
	if type logger >/dev/null 2>&1; then
		logger -t vdrshutdown-wakeup "$@"
	fi
}

# A little bit complicated, but this is used to really check if a reboot is needed
# nvram gets confused when setting the same time a second time
# (when first shutdown-try fails for some reason).

reboot_mark_file="${shutdown_data_dir}"/shutdown-need-reboot
_need_reboot=0

# to be called from wakeup-method to signalize need for reboot
set_reboot_needed() {
	date +%s > "${reboot_mark_file}"
	_need_reboot=1
}

need_reboot() {
	local TSTAMP= BOOT=

	# we already know we should reboot
	[ "${_need_reboot}" = 1 ] && return 0

	[ -e "${reboot_mark_file}" ] || return 1
	read TSTAMP < "${reboot_mark_file}"
	BOOT=$(stat -c %Y /proc)

	# requested reboot after last boot
	if [ "$BOOT" -lt "$TSTAMP" ]; then
		_need_reboot=1
		return 0
	fi

	return 1
}


WAKEUP_METHOD="${WAKEUP_METHOD:-rtc acpi nvram none}"

run_wakeup_method()
{
	local mod="$1"
	(
		if [ -f "${shutdown_script_dir}/wakeup-${mod}.sh" ]; then
			. ${shutdown_script_dir}/wakeup-${mod}.sh
		else
			return 1
		fi
	)
}

_set_wakeup() {
	for method in ${WAKEUP_METHOD}; do
		if run_wakeup_method "${method}"; then
			return 0
		fi
	done
	return 1
}

_do_shutdown() {
	SHUTDOWN_METHOD=halt
	if need_reboot; then
		SHUTDOWN_METHOD=reboot
	fi

	f="${shutdown_script_dir}/shutdown-${SHUTDOWN_METHOD}.sh"

	if [ "${DRY_SHUTDOWN}" = "1" ]; then
		mesg "dry run: NOT executing shutdown-${SHUTDOWN_METHOD}.sh"
		return 0
	fi

	if [ -f "$f" ]; then
		mesg "Executing shutdown-${SHUTDOWN_METHOD}.sh"
		. "$f"
	fi
	return 0
}

_set_wakeup || return 98
_do_shutdown || return 97

exit 0

