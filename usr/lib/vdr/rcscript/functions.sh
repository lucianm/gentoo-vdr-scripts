
test -z "${vdr_rcdir}" && vdr_rcdir=/usr/lib/vdr/rcscripts

plugin_dir=/usr/lib/vdr/plugins
test -d ${plugin_dir} || plugin_dir=/usr/lib/vdr

pidof=/sbin/pidof
test -x /bin/pidof && pidof=/bin/pidof

test_vdr_process()
{
	${pidof} /usr/bin/vdr >/dev/null
}

getvdrversion()
{
	vdrversion=$(awk '/VDRVERSION/ { gsub("\"","",$3); print $3 }' /usr/include/vdr/config.h)
}

init_params()
{
	# init array for parameters
	opt_idx=0
	unset vdropts
	declare -a vdropts
}

add_param()
{
	vdropts[opt_idx]="$1"
	opt_idx=$[opt_idx+1]
}

init_plugin_params()
{
	# init array for parameters
	plugin_opt_idx=0
	unset vdrplugin_opts
	declare -a vdrplugin_opts
}

add_plugin_param()
{
	vdrplugin_opts[plugin_opt_idx]="$1"
	plugin_opt_idx=$[plugin_opt_idx+1]
}

#
# void load_addons_prefixed(char *prefix)
#
load_addons_prefixed()
{
	abort=0
	for addon in ${vdr_rcdir}/${1}-*.sh; do
		[[ -f "${addon}" ]] && source "${addon}"
		[[ "$abort" != "0" ]] && break
	done
	return $abort
}

load_addon()
{
	[[ -f "${vdr_rcdir}/${1}.sh" ]] && source "${vdr_rcdir}/${1}.sh"
	return $abort
}

load_plugin()
{
	local PLUGIN="${1}"
	if [[ ! -f "${plugin_dir}/libvdr-${PLUGIN}.so.${vdrversion}" ]]; then
		ewarn "Plugin ${PLUGIN} not found, starting without it."
		return 1
	fi

	unset _EXTRAOPTS
	if [[ -f /etc/conf.d/vdr.${PLUGIN} ]]; then
		source /etc/conf.d/vdr.${PLUGIN}
	fi
	init_plugin_params ${PLUGIN}
	add_plugin_param "--plugin=${PLUGIN}"
	load_addon plugin-${PLUGIN}

	add_param "${vdrplugin_opts[*]} ${_EXTRAOPTS}"
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
	waited=0
	while [[ "${waited}" -lt "${waittime}" ]]; do
		eval ${cond}
		case "$?" in
			0) einfo waited ${waited} seconds; return 0 ;;
			2) einfo waited ${waited} seconds; return 2 ;;
		esac
		waited=$[waited+1]
		sleep 1
	done
	einfo waited ${waited} seconds
	return 1
}

add_wait_condition() {
	waitconditions="${waitconditions} ${1} "
}

wait_for_multiple_condition() {
	ret=0
	condition_msg=""
	for cond in ${waitconditions}; do
		eval ${cond}
		case "$?" in
			0)
				waitconditions=${waitconditions/${cond} /}
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
