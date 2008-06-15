# $Id$

# Manages loading of plugins (i.e. creating command-line-options for vdr)
#
# Main entry-points are:
#  load_plugin - Checks for loadable Plugin and calls functions
#                in Plugin-rc-addon when existing
#  init_plugin_params - Prepares list of command-line-options for one plugin
#                       Adds --plugin="${NAME}" option
#
# Function callable by plugin rc-addon:
#   add_plugin_param "-v -d /directory1"  - This adds these options to command-line of plugin
#

init_tmp_dirs() {
	if [ ! -d /var/vdr/tmp ]; then
		mkdir /var/vdr/tmp
		chown vdr:vdr /var/vdr/tmp
	fi
}

create_header_checksum() {
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
		vdr_checksum=/var/vdr/tmp/header-md5-vdr

		rm ${vdr_checksum} 2>/dev/null
		(
			cd /usr/include/vdr
			md5sum *.h libsi/*.h|LC_ALL=C sort --key=2
		) > ${vdr_checksum}
	fi
	PLUGIN_CHECK_MD5=yes
}

load_plugin_list() {
	PLUGINS=""
	rm -f "${LOADED_PLUGINS_FILE}"

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
	fi
}

load_plugin_list_stop() {
	PLUGINS=""
	if [ -e "${LOADED_PLUGINS_FILE}" ]; then
		PLUGINS=$(cat "${LOADED_PLUGINS_FILE}" )
	fi
}

init_plugin_loader() {
	init_tmp_dirs
	create_header_checksum

	# Load list of plugins which were started to exec correct rcaddons
	LOADED_PLUGINS_FILE=/var/vdr/tmp/loaded_plugins
	PLUGINS=""
	skipped_plugins_patchlevel=""
	skipped_plugins_not_found=""

	local skip_tmp_file="/var/vdr/tmp/plugins_skipped"
	rm -f "${skip_tmp_file}"*
}

print_skip_header() {
	if [ "${skip_header_printed}" != "1" ]; then
		ewarn "  Skipped these plugins:"
		vdr_log "Skipped these plugins:"
		skip_header_printed=1
	fi
}

finish_plugin_loader() {
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

load_plugin()
{
	local PLUGIN="${1}"
	local call_func="${2}"
	SKIP_PLUGIN=0

	unset _EXTRAOPTS
	if [ -f "/etc/conf.d/vdr.${PLUGIN}" ]; then
		. /etc/conf.d/vdr.${PLUGIN}
	fi

	load_addon plugin-${PLUGIN} ${call_func}
}

init_plugin_params()
{
	# init list of plugin parameters
	vdrplugin_opts="--plugin=$1"
}

add_plugin_param()
{
	# append new parameter
	vdrplugin_opts="${vdrplugin_opts} $1"
}

skip_plugin() {
	# globally set this to signal skipping
	SKIP_PLUGIN=1

	# count the skipped ones
	#SKIP_COUNT=$(($SKIP_COUNT+1))

	local PLUGIN="$1"
	local ERROR="$2"

	local skip_tmp_file="/var/vdr/tmp/plugins_skipped"
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
	if [ "${SKIP_PLUGIN}" = "0" ]; then
		# for not-skipped plugins, add the param to the vdr-call
		add_param "${vdrplugin_opts} ${_EXTRAOPTS}"
	fi
}

store_loaded_plugin() {
	if [ "${SKIP_PLUGIN}" = "0" ]; then
		# Store list of loaded plugins
		echo "$1" >> "${LOADED_PLUGINS_FILE}"
	fi
}

