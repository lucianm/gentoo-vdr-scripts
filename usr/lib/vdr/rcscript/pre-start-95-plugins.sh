# $Id$

include plugin-functions

addon_main() {
	local PLUGIN
	for PLUGIN in ${PLUGINS}; do
		SKIP_PLUGIN=0

		init_plugin_params ${PLUGIN}

		load_plugin ${PLUGIN} plugin_pre_vdr_start
		[[ "${SKIP_PLUGIN}" == "1" ]] && continue

		add_param "${vdrplugin_opts[*]} ${_EXTRAOPTS}"
	done
}

