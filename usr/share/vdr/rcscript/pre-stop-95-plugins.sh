# $Id$


addon_main() {
	include plugin-functions
	init_plugin_loader
	load_plugin_list_stop

	for PLUGIN in ${PLUGINS}; do
		load_plugin ${PLUGIN} plugin_pre_vdr_stop || return 1
	done
	return 0
}

