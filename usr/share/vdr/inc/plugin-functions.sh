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


init_plugin_loader() {
	if [ ! -d /var/vdr/tmp ]; then
		mkdir /var/vdr/tmp
		chown vdr:vdr /var/vdr/tmp
	fi

	plugin_dir=$(awk '/^PLUGINLIBDIR/{ print $3 }' /usr/include/vdr/Make.config)
	if [ -n "${plugin_dir}" ]; then
		plugin_dir=/usr/lib/vdr/plugins
	fi

	if type md5sum >/dev/null 2>&1; then
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
	else
		PLUGIN_CHECK_MD5=no
	fi


	# Loading configuration

	# old conf-system - PLUGINS in /etc/conf.d/vdr
	# now this gets cleared in here
	PLUGINS=""

	# Load list of plugins which were started to exec correct rcaddons
	local LOADED_PLUGINS_FILE=/var/vdr/tmp/loaded_plugins
	if [ "${INIT_PHASE}" = "stop" ] && [ -e "${LOADED_PLUGINS_FILE}" ]; then
		PLUGINS=$(cat ${LOADED_PLUGINS_FILE} )
	else
		rm -f ${LOADED_PLUGINS_FILE}

		# new conf-system - /etc/conf.d/vdr.plugins
		local PLUGIN_CONF=/etc/conf.d/vdr.plugins
		if [ -f "${PLUGIN_CONF}" ]; then
			local line
			exec 3<${PLUGIN_CONF}
			while read line <&3; do
				[ "${line}" = "" ] && continue
				[ "${line#"#"}" != "${line}" ] && continue
				PLUGIN="${line}"
				PLUGINS="${PLUGINS} ${PLUGIN}"
			done
			exec 3<&-
		fi

		# Store list of loaded plugins
		echo ${PLUGINS} > ${LOADED_PLUGINS_FILE}
	fi
}

check_plugin() {
	local PLUGIN="${1}"
	local plugin_file="${plugin_dir}/libvdr-${PLUGIN}.so.${APIVERSION}"

	if [ ! -f "${plugin_file}" ]; then
		skip_plugin "${PLUGIN}" "plugin not found"
		return
	fi

	local plugin_checksum_file=${vdr_checksum_dir}/header-md5-vdr-${PLUGIN}
	if [ "${PLUGIN_CHECK_MD5}" = "yes" ] && [ -e "${plugin_checksum_file}" ]; then
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
	SKIP_PLUGIN=0

	# Only check when starting vdr
	if [ "${INIT_PHASE}" != "stop" ]; then
		check_plugin ${PLUGIN}
	fi
	[ "${SKIP_PLUGIN}" = "1" ] && return

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
	SKIP_PLUGIN=1
	if [ -n "${1}" ] && [ "${addon_prefix}" = "pre-start" ]; then
		ewarn "  ${1}: ${2}"
		vdr_log "Skipped ${1}: ${2}"
	fi
}

add_plugin_params_to_vdr_call() {
	if [ "${SKIP_PLUGIN}" = "0" ]; then
		# for not-skipped plugins, add the param to the vdr-call
		add_param "${vdrplugin_opts} ${_EXTRAOPTS}"
	fi
}

init_plugin_loader

