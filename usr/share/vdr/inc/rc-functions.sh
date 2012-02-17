# $Id$

# Contains:
#   manage all vdr-command-line-options
#   Loading of rc-script addons
#   General routine to wait for conditions (svdrp/existing dvb-device-nodes ...)
#

: ${vdr_rc_dir:=/usr/share/vdr/rcscript}
: ${SCRIPT_DEBUG_LEVEL:=0}
SCRIPT_API=2

read_caps

test_vdr_process() {
	pidof "${VDR_BIN}" >/dev/null
}

getvdrversion() {
	local include_dir=/usr/include/vdr
	VDRVERSION=$(awk -F'"' '/define VDRVERSION/ {print $2}' ${include_dir}/config.h)
	APIVERSION=$(awk -F'"' '/define APIVERSION/ {print $2}' ${include_dir}/config.h)
	[ -z "${APIVERSION}" ] && APIVERSION="${VDRVERSION}"

	VDRNAME=vdr
	yesno "${SHOW_VDR_VERSION}" && VDRNAME=${VDRNAME}-${VDRVERSION}
}

[ -z "${VDR_BIN}" ] && VDR_BIN=/usr/bin/vdr
getvdrversion

getvdrversnum() {
	local include_dir=/usr/include/vdr
	VDRVERSNUM=$(awk '/define VDRVERSNUM/ {print $3}' ${include_dir}/config.h)
}
getvdrversnum

init_params() {
	# init variables for vdr/daemonctrl parameters
	vdr_opts=""
	daemonctrl_opts=""
}


add_daemonctrl_param() {
	while [ -n "$1" ]; do
		daemonctrl_opts="${daemonctrl_opts} '$1'"
		shift;
	done
}

add_param() {
	while [ -n "$1" ]; do
		vdr_opts="${vdr_opts} '$1'"
		shift
	done
}

#
# void load_addons_prefixed(char *prefix)
#
load_addons_prefixed() {
	local addon_prefix=$1 call_func=${2:-addon_main} basename= ret=0

	for addon in ${vdr_rc_dir}/${addon_prefix}-*.sh; do
		load_addon ${addon} ${call_func}
		ret="$?"
		if [ "${ret}" != "0" ]; then
			ewarn "Addon ${addon} failed."
			break
		fi
	done
	return $ret
}

load_addon() {
	local addon=${1} func=${2:-addon_main}
	local fname="${vdr_rc_dir}/${addon}.sh"
	[ -f ${fname} ] || fname="${addon}"
	[ -f "${fname}" ] || return 0

	# fallback
	eval "${func}() { :; }"
	
	# source addon
	sh -n "${fname}" || return 1
	. "${fname}" || return 1

	# execute requested function
	eval ${func}
}

has_debuglevel() {
	[ "${SCRIPT_DEBUG_LEVEL}" -ge "${1}" ]
}

debug_msg() {
	has_debuglevel 1 && einfo "$@"
}

# should no longer be used
einfo_level1() {
	debug_msg "$@"
}
einfo_level2() {
	debug_msg "$@"
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
	local waittime="$1" cond="$2" waited=0 status=1

	eval ${cond}; status=$?
	while [ "${status}" = 1 -a "${waited}" -lt "${waittime}" ]; do
		sleep 1; waited=$(($waited+1))

		eval ${cond}; status=$?
	done
	debug_msg "waited ${waited} seconds on ${cond}"
	return $status
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

error_mesg() {
	eerror "$@"
	vdr_log "$@"
}
