# $Id$
addon_main() {
	for PLUGIN in ${PLUGINS}; do
		load_plugin ${PLUGIN} plugin_pre_vdr_stop
	done
}

