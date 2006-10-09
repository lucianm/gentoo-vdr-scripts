# $Id$

include plugin-functions

addon_main() {
	local PLUGIN
	local SKIP_COUNT=0
	local PLUGIN_COUNT=0
	for PLUGIN in ${PLUGINS}; do
		: $(( PLUGIN_COUNT++ ))
		init_plugin_params ${PLUGIN}

		load_plugin ${PLUGIN} plugin_pre_vdr_start

		if [[ "${SKIP_PLUGIN}" == "1" ]]; then
			: $(( SKIP_COUNT++ ))
			continue
		fi

		if [[ -z ${_EXTRAOPTS} ]]; then
			add_param "${vdrplugin_opts[*]}"
		else
			add_param "${vdrplugin_opts[*]} ${_EXTRAOPTS}"
		fi
	done

	if [[ ${SKIP_COUNT} > 0 ]]; then
		if has_debuglevel 1; then
			eerror "${SKIP_COUNT} Plugins out of ${PLUGIN_COUNT} could not be loaded!"
		else
			eerror "Some plugins could not be loaded!"
		fi
	else
		einfo_level2 "All ${PLUGIN_COUNT} Plugins loaded."
	fi
	return 0
}

