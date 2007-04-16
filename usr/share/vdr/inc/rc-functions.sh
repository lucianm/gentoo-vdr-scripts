# $Id$

# Contains:
#   manage all vdr-command-line-options
#   Loading of rc-script addons
#   General routine to wait for conditions (svdrp/existing dvb-device-nodes ...)
#   Starting and stopping of external watchdog
#

include message-functions

: ${vdr_rc_dir:=/usr/share/vdr/rcscript}
: ${vdr_old_rc_dir:=/usr/lib/vdr/rcscript}
: ${SCRIPT_DEBUG_LEVEL:=0}
SCRIPT_API=2

pidof=/sbin/pidof
test -x /bin/pidof && pidof=/bin/pidof

. /etc/conf.d/vdr.watchdogd
ENABLE_EXTERNAL_WATCHDOG=${ENABLE_EXTERNAL_WATCHDOG:-no}

read_caps

test_vdr_process()
{
	${pidof} /usr/bin/vdr >/dev/null
}

getvdrversion()
{
	VDRVERSION=$(awk -F'"' '/define VDRVERSION/ {print $2}' /usr/include/vdr/config.h)
	APIVERSION=$(awk -F'"' '/define APIVERSION/ {print $2}' /usr/include/vdr/config.h)
	[ -z "${APIVERSION}" ] && APIVERSION="${VDRVERSION}"

	case ${SHOW_VDR_VERSION:=no} in
		yes)	VDRNAME=vdr-${VDRVERSION}  ;;
		*)	VDRNAME=vdr ;;
	esac
}

getvdrversion

init_daemonctrl_params()
{
	# init array for parameters
	daemonctrl_idx=0
	unset daemonctrl_opts
	declare -a daemonctrl_opts
}

add_daemonctrl_param()
{
	while [ -n "$1" ]; do
		daemonctrl_opts[daemonctrl_idx]="$1"
		daemonctrl_idx=$((daemonctrl_idx+1))
		shift;
	done
}

init_params()
{
	# init array for parameters
	vdr_idx=0
	unset vdr_opts
	declare -a vdr_opts
}

add_param()
{
	while [ -n "$1" ]; do
		vdr_opts[vdr_idx]="$1"
		vdr_idx=$((vdr_idx+1))
		shift
	done
}

#
# void load_addons_prefixed(char *prefix)
#
load_addons_prefixed()
{
	addon_prefix=${1}
	local call_func=${2:-addon_main}
	local basename=""
	local ret=0

	for addon in ${vdr_rc_dir}/${addon_prefix}-*.sh; do
		load_addon ${addon} ${call_func}
		ret="$?"
		if [ "${ret}" != "0" ]; then
			einfo_level2 Addon ${addon} failed.
			break
		fi
	done
	return $ret
}

load_addon()
{
	local addon=${1}
	local call_func=${2:-addon_main}
	eval "${call_func}() { :; }"

	local fname
	if [ "${addon#/}" != "${addon}" ] && [ -f "${addon}" ]; then
		fname="${addon}"
	elif [ -f "${vdr_rc_dir}/${addon}.sh" ]; then
		fname="${vdr_rc_dir}/${addon}.sh"
	elif [ -f "${vdr_old_rc_dir}/${addon}.sh" ]; then
		fname="${vdr_old_rc_dir}/${addon}.sh"
	fi
	
	# source addon
	sh -n "${fname}" || return 1
	. "${fname}" || return 1

	# execute requested function
	eval ${call_func}
	local ret="$?"
	return $ret
}

has_debuglevel() {
	[ "${SCRIPT_DEBUG_LEVEL}" -ge "${1}" ]
}

einfo_level1() {
	has_debuglevel 1 && einfo "$@"
}

einfo_level2() {
	has_debuglevel 2 && einfo "$@"
}

einfo_debug() {
	has_debuglevel 3 && einfo "$@"
}

quote_parameters() {
	local item
	local txt=""
	for item; do
		case "${item}" in
			*\ *)
				txt="${txt} \"${item}\""
				;;
			*)
				txt="${txt} ${item}"
				;;
		esac
	done
	echo "${txt}"
}

# int waitfor (int waittime, void (*condition)(void))
# returns
#   0 when condition returns true
#   1 on timeout
#   2 on other failure

# condition should return
#   0 for success
#   1 for call later again
#   2 failure, break waiting

waitfor() {
	local waittime="${1}"
	local cond="${2}"
	local ok
	local waited=0
	while [ "${waited}" -lt "${waittime}" ]; do
		eval ${cond}
		case "$?" in
			0) einfo_debug waited ${waited} seconds; return 0 ;;
			2) einfo_debug waited ${waited} seconds; return 2 ;;
		esac
		waited=$((waited+1))
		sleep 1
	done
	einfo_level1 waited ${waited} seconds
	return 1
}

add_wait_condition() {
	eval cond_done_$1=0
	waitconditions="${waitconditions} $1 "
}

wait_for_multiple_condition() {
	local already_done
	ret=0
	condition_msg=""
	for cond in ${waitconditions}; do
		# check if marked as done
		eval already_done=\$cond_done_${cond}
		[ "${already_done}" = 1 ] && continue

		eval ${cond}
		case "$?" in
			0)
				eval cond_done_${cond}=1
				;;
			1)
				ret=1
				;;
			2)
				return 2
				;;
		esac
	done
	return $ret
}

stop_watchdog() {
	if [ "${ENABLE_EXTERNAL_WATCHDOG}" = "yes" ]; then
		ebegin "Stopping vdr watchdog"
		start-stop-daemon --stop --pidfile /var/run/vdrwatchdog.pid
		eend $? "failed stopping watchdog"
	fi
}

start_watchdog() {
	if [ "${ENABLE_EXTERNAL_WATCHDOG}" = "yes" ]; then
		WATCHDOG_LOGFILE=${WATCHDOG_LOGFILE:-/dev/null}
		ebegin "Starting vdr watchdog"
		start-stop-daemon \
			--start \
			--background \
			--make-pidfile \
			--pidfile /var/run/vdrwatchdog.pid \
			--exec /usr/sbin/vdr-watchdogd \
			-- ${WATCHDOG_LOGFILE}
		eend $? "failed starting vdr watchdog"
	fi
}

error_mesg() {
	logger "vdr-scripts: Error: $@"
	vdr_eerror "$@"
}
