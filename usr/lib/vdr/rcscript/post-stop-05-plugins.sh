addon_main() {
	for PLUGIN in ${PLUGINS}; do
		load_plugin ${PLUGIN} plugin_post_vdr_stop
	done
}
