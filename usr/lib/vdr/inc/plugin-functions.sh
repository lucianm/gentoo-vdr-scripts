# $Id$


init_plugin_loader() {
	PLUGIN_CHECK_MD5=no

	if ! which md5sum >/dev/null 2>&1; then
		return
	fi

	if [[ ! -d /var/vdr/tmp ]]; then
		mkdir /var/vdr/tmp
		chown vdr:vdr /var/vdr/tmp
	fi


	plugin_dir=$(awk '/^PLUGINLIBDIR/{ print $3 }' /usr/include/vdr/Make.config)
	if [[ -n ${plugin_dir} ]]; then
		plugin_dir=/usr/lib/vdr/plugins
	fi

	vdr_checksum_dir="${plugin_dir%/plugins}/checksums"
	vdr_checksum=${vdr_checksum_dir}/header-md5-vdr

	if [[ ! -f ${vdr_checksum} ]]; then
		vdr_checksum=/var/vdr/tmp/header-md5-vdr

		rm ${vdr_checksum} 2>/dev/null
		(
			cd /usr/include/vdr
			md5sum *.h libsi/*.h|LC_ALL=C sort --key=2
		) > ${vdr_checksum}
	fi

	PLUGIN_CHECK_MD5=yes
}

check_plugin() {
	local PLUGIN="${1}"
	local plugin_file="${plugin_dir}/libvdr-${PLUGIN}.so.${APIVERSION}"

	if [[ ! -f "${plugin_file}" ]]; then
		skip_plugin "${PLUGIN}" "plugin not found"
		return
	fi

	local plugin_checksum_file=${vdr_checksum_dir}/header-md5-vdr-${PLUGIN}
	if [[ "${PLUGIN_CHECK_MD5}" == "yes" && -e ${plugin_checksum_file} ]]; then
		if ! diff ${vdr_checksum} ${plugin_checksum_file} >/dev/null; then
			skip_plugin "${PLUGIN}" "wrong vdr-patchlevel"
			return
		fi
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
	if [[ -n "${1}" && "${addon_prefix}" == "pre-start" ]]; then

		# einmal Kopfzeile anzeigen
		[[ ${SKIP_PLUGIN_HEADER_PRINTED} != 1 ]] && vdr_eerror "Unable to load these plugins:"
		SKIP_PLUGIN_HEADER_PRINTED=1
		
		vdr_eerror "  ${1}: ${2}"
	fi
}

init_plugin_loader

