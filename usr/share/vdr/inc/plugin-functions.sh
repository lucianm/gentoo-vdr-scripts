# $Id$

# Manages loading of plugins (i.e. creating command-line-options for vdr)

init_tmp_dirs() {
	PL_TMP=/var/vdr/tmp
	if [ ! -d "${PL_TMP}" ]; then
		mkdir "${PL_TMP}"
		chown vdr:vdr "${PL_TMP}"
	fi
}

init_header_checksum() {
	plugin_dir=$(awk '/^PLUGINLIBDIR/{ print $3 }' /usr/include/vdr/Make.config)
	if [ -n "${plugin_dir}" ]; then
		plugin_dir=/usr/lib/vdr/plugins
	fi

	if ! type md5sum >/dev/null 2>&1; then
		PLUGIN_CHECK_MD5=no
		return
	fi

	vdr_checksum_dir="${plugin_dir%/plugins}/checksums"
	vdr_checksum=${vdr_checksum_dir}/header-md5-vdr

	if [ ! -f "${vdr_checksum}" ]; then
		vdr_checksum="${PL_TMP}"/header-md5-vdr

		rm -f ${vdr_checksum} 2>/dev/null
		(
			cd /usr/include/vdr
			md5sum *.h libsi/*.h|LC_ALL=C sort --key=2
		) > ${vdr_checksum}
	fi
	PLUGIN_CHECK_MD5=yes
}

print_skip_header() {
	if [ "${skip_header_printed}" != "1" ]; then
		ewarn "  Skipped these plugins:"
		vdr_log "Skipped these plugins:"
		skip_header_printed=1
	fi
}

load_plugin_list_start() {
	rm -f "${LOADED_PLUGINS_FILE}"
	# needed for plugin patchlevel check
	init_header_checksum

	local PLUGIN_CONF=/etc/conf.d/vdr.plugins PLUGIN= line=
	if [ -f "${PLUGIN_CONF}" ]; then
		exec 3<${PLUGIN_CONF}
		while read line <&3; do
			[ "${line}" = "" ] && continue
			[ "${line#"#"}" != "${line}" ] && continue
			PLUGIN="${line}"
			check_plugin "${PLUGIN}" || continue
			PLUGINS="${PLUGINS} ${PLUGIN}"
		done
		exec 3<&-
	
		# result of checks
		if [ -n "${skipped_plugins_patchlevel}" ]; then
			print_skip_header
			ewarn "    Wrong Patchlevel: ${skipped_plugins_patchlevel}"
			vdr_log "Wrong Patchlevel: ${skipped_plugins_patchlevel}"
		fi
		if [ -n "${skipped_plugins_not_found}" ]; then
			print_skip_header
			ewarn "    Not Existing:     ${skipped_plugins_not_found}"
			vdr_log "Not Existing: ${skipped_plugins_not_found}"
		fi
	fi
}

load_plugin_list_stop() {
	if [ -e "${LOADED_PLUGINS_FILE}" ]; then
		PLUGINS=$(cat "${LOADED_PLUGINS_FILE}" )
	fi
}

init_plugin_loader() {
	local phase="$1"
	init_tmp_dirs

	# Load list of plugins which were started to exec correct rcaddons
	LOADED_PLUGINS_FILE="${PL_TMP}"/loaded_plugins
	PLUGINS=""
	skipped_plugins_patchlevel=""
	skipped_plugins_not_found=""

	local skip_tmp_file="${PL_TMP}/plugins_skipped"
	rm -f "${skip_tmp_file}"*

	case "$phase" in
		start)	load_plugin_list_start ;;
		stop)	load_plugin_list_stop ;;
	esac
}

check_plugin() {
	local PLUGIN="${1}"
	local plugin_file="${plugin_dir}/libvdr-${PLUGIN}.so.${APIVERSION}"

	if [ ! -f "${plugin_file}" ]; then
		skip_plugin "${PLUGIN}" "NOT_FOUND"
		return 1
	fi

	local plugin_checksum_file=${vdr_checksum_dir}/header-md5-vdr-${PLUGIN}
	if [ "${PLUGIN_CHECK_MD5}" = "yes" ] && [ -e "${plugin_checksum_file}" ]; then
		if ! diff ${vdr_checksum} ${plugin_checksum_file} >/dev/null; then
			skip_plugin "${PLUGIN}" "PATCHLEVEL"
			return 1
		fi
	fi

	#if ldd ${plugin_file} 2>/dev/null | grep -q "not found"; then
	#	skip_plugin "${PLUGIN}" "unresolved deps - please use revdep-rebuild"
	#	return
	#fi
	return 0
}

run_plugin_addon()
{
	local PLUGIN="${1}"
	local call_func="${2}"

	unset _EXTRAOPTS
	if [ -f "/etc/conf.d/vdr.${PLUGIN}" ]; then
		. /etc/conf.d/vdr.${PLUGIN}
	fi

	load_addon plugin-${PLUGIN} ${call_func}
}

add_plugin_param()
{
	# append new parameter
	vdrplugin_opts="${vdrplugin_opts} $1"
}

skip_plugin() {
	# globally set this to signal skipping
	SKIP_PLUGIN=1

	local PLUGIN="$1"
	local ERROR="$2"

	local skip_tmp_file="${PL_TMP}/plugins_skipped"
	echo "${PLUGIN}" >> "${skip_tmp_file}_ALL" || return 1
	echo "${PLUGIN}" >> "${skip_tmp_file}_${ERROR}" || return 1

	case "${ERROR}" in
	PATCHLEVEL)
		skipped_plugins_patchlevel="${skipped_plugins_patchlevel} ${PLUGIN}"
		;;
	NOT_FOUND)
		skipped_plugins_not_found="${skipped_plugins_not_found} ${PLUGIN}"
		;;
	esac
	return 0
}

add_plugin_params_to_vdr_call() {
	# add the param to the vdr-call
	add_param "${vdrplugin_opts} ${_EXTRAOPTS}"
}

loop_all_plugins() {
	local PLUGIN func="$1" prepare_cmdline=0

	case "$func" in
	plugin_pre_vdr_start)
		for PLUGIN in ${PLUGINS}; do
			SKIP_PLUGIN=0
			vdrplugin_opts="--plugin=${PLUGIN}"
			run_plugin_addon "${PLUGIN}" "${func}" || return 1
			[ "${SKIP_PLUGIN}" = 1 ] && continue

        	        add_plugin_params_to_vdr_call
			echo "${PLUGIN}" >> "${LOADED_PLUGINS_FILE}"
		done
		;;
	*)
		for PLUGIN in ${PLUGINS}; do
			run_plugin_addon "${PLUGIN}" "${func}" || return 1
		done
		;;
	esac
	return 0
}
