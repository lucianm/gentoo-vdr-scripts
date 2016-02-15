
# Manages loading of plugins (i.e. creating command-line-options for vdr)


include argsdir-functions

init_tmp_dirs() {
	PL_TMP="${vdr_user_home}/tmp"
	if [ ! -d "${PL_TMP}" ]; then
		mkdir "${PL_TMP}"
		chown vdr:vdr "${PL_TMP}"
	fi
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
	prepare_plugin_checks

	local CFG_PLG_SYMLINKS=$(get_configured_cfgs)
	if [ -n "${CFG_PLG_SYMLINKS}" ]; then
		for CFG_SYM in ${CFG_PLG_SYMLINKS}; do
			PLUGIN=$(cfg_path_2_plg_name $ARGSDIR/$CFG_SYM)
			if check_plugin "${PLUGIN}"; then
				# list plugins only once 
				[ "${PLUGINS/$PLUGIN}" = "$PLUGINS" ] && PLUGINS="${PLUGINS} ${PLUGIN}"
			else
				# move to skipped directory
				mv -f $ARGSDIR/$CFG_SYM $DIR_SKIPPED
			fi
		done

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
	init_skipped_dir

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

prepare_plugin_checks() {
	# find plugin lib dir, needed for multilib ...
	plugin_dir=$(pkg-config --variable=libdir vdr)

	# needed for plugin patchlevel check
	vdr_checksum_dir="${plugin_dir%/plugins}/checksums"
	vdr_checksum="${PL_TMP}"/header-md5-vdr

	_PLUGIN_CHECK_HEADER=false
	if yesno "${PLUGIN_CHECK_PATCHLEVEL:-yes}"; then
		vdr-get-header-checksum > "${vdr_checksum}" && _PLUGIN_CHECK_HEADER=true
	fi
}

check_plugin() {
	local PLUGIN="${1}"
	local plugin_file="${plugin_dir}/libvdr-${PLUGIN}.so.${APIVERSION}"

	if [ ! -f "${plugin_file}" ]; then
		skip_plugin "${PLUGIN}" "NOT_FOUND"
		return 1
	fi

	local plugin_checksum_file=${vdr_checksum_dir}/header-md5-vdr-${PLUGIN}
	if ${_PLUGIN_CHECK_HEADER} && [ -e "${plugin_checksum_file}" ]; then
		if ! cmp -s ${vdr_checksum} ${plugin_checksum_file}; then
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
	# dummy, kept only for compatibility
	local dummy_variable
	echo $dummy_variable
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

loop_all_plugins() {
	local PLUGIN func="$1" prepare_cmdline=0

	case "$func" in
	plugin_pre_vdr_start)
		for PLUGIN in ${PLUGINS}; do
			SKIP_PLUGIN=0
			run_plugin_addon "${PLUGIN}" "${func}" || return 1
			[ "${SKIP_PLUGIN}" = 1 ] && continue
			echo "${PLUGIN}" >> "${LOADED_PLUGINS_FILE}"
		done
		;;
	*)
		for PLUGIN in $(cat ${LOADED_PLUGINS_FILE}); do
			run_plugin_addon "${PLUGIN}" "${func}" || return 1
		done
		;;
	esac
	return 0
}
