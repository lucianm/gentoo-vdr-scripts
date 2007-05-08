# $Id$

include plugin-functions

addon_main() {
	local PLUGIN
	local SKIP_COUNT=0
	local PLUGIN_COUNT=0

	for PLUGIN in ${PLUGINS}; do
		PLUGIN_COUNT=$(($PLUGIN_COUNT+1))

		# init parameters
		init_plugin_params ${PLUGIN}

		# call rc-addon of plugin
		load_plugin ${PLUGIN} plugin_pre_vdr_start

		# add to commandline
		add_plugin_params_to_vdr_call

		# count the skipped ones
		if [ "${SKIP_PLUGIN}" = "1" ]; then
			SKIP_COUNT=$(($SKIP_COUNT+1))
		fi

	done


	if [ "${SKIP_COUNT}" -gt 0 ]; then
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

