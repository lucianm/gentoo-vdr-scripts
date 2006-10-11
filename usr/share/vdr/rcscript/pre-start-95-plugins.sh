# $Id$

include plugin-functions

addon_main() {
	local PLUGIN
	local SKIP_COUNT=0
	local PLUGIN_COUNT=0

	# old conf-system - PLUGINS in /etc/conf.d/vdr
	# now this gets cleared in here
	PLUGINS=""

	# new conf-system - /etc/conf.d/vdr.plugins
	local PLUGIN_CONF=/etc/conf.d/vdr.plugins
	if [[ -f ${PLUGIN_CONF} ]]; then
		local line
		exec 3<${PLUGIN_CONF}
		while read -u 3 line; do
			[[ ${line} == "" ]] && continue
			[[ ${line:0:1} == "#" ]] && continue
			PLUGIN="${line}"
			PLUGINS="${PLUGINS} ${PLUGIN}"
		done
		exec 3<&-
	fi

	for PLUGIN in ${PLUGINS}; do
		: $(( PLUGIN_COUNT++ ))

		# init parameters
		init_plugin_params ${PLUGIN}

		# call rc-addon of plugin
		load_plugin ${PLUGIN} plugin_pre_vdr_start

		# add to commandline
		add_plugin_params_to_vdr_call

		# count the skipped ones
		if [[ "${SKIP_PLUGIN}" == "1" ]]; then
			: $(( SKIP_COUNT++ ))
		fi

	done


	if [[ ${SKIP_COUNT} > 0 ]]; then
		if has_debuglevel 1; then
			eerror "  ${SKIP_COUNT} Plugins out of ${PLUGIN_COUNT} could not be loaded!"
		else
			eerror "  Some plugins could not be loaded!"
		fi
	else
		einfo_level2 "  All ${PLUGIN_COUNT} Plugins loaded."
	fi
	return 0
}

