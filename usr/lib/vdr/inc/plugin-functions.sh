# $Id$


check_plugin() {
	local PLUGIN="${1}"
	local plugin_file="${plugin_dir}/libvdr-${PLUGIN}.so.${vdrversion}"

	if [[ ! -f "${plugin_file}" ]]; then
		skip_plugin "${PLUGIN}" "plugin not found"
		return
	fi

	#if ldd ${plugin_file} 2>/dev/null | grep -q "not found"; then
	#	skip_plugin "${PLUGIN}" "unresolved deps - please use revdep-rebuild"
	#	return
	#fi
}

load_plugin()
{
	local PLUGIN="${1}"
	local call_func="${2}"

	check_plugin ${PLUGIN}
	[[ "${SKIP_PLUGIN}" == "1" ]] && return

	unset _EXTRAOPTS
	if [[ -f /etc/conf.d/vdr.${PLUGIN} ]]; then
		source /etc/conf.d/vdr.${PLUGIN}
	fi

	load_addon plugin-${PLUGIN} ${call_func}
}

init_plugin_params()
{
	# init array for parameters
	plugin_opt_idx=1
	vdrplugin_opts=("--plugin=${1}")
}

add_plugin_param()
{
	vdrplugin_opts[plugin_opt_idx]="$1"
	plugin_opt_idx=$[plugin_opt_idx+1]
}

skip_plugin() {
	SKIP_PLUGIN=1
	if [[ -n "${1}" ]]; then
		einfo "Skipped loading Plugin ${1}: ${2}"
	fi
}

