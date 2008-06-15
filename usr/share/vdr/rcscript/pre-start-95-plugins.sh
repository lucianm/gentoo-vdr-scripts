# $Id$


addon_main() {
	include plugin-functions
	init_plugin_loader
	load_plugin_list

	local PLUGIN

	for PLUGIN in ${PLUGINS}; do
		# init parameters
		init_plugin_params ${PLUGIN}

		# call rc-addon of plugin
		load_plugin ${PLUGIN} plugin_pre_vdr_start || return 1

		# add to commandline
		add_plugin_params_to_vdr_call

		store_loaded_plugin ${PLUGIN}
	done

	finish_plugin_loader

	return 0
}

