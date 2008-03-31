# $Id$

include plugin-functions

addon_main() {
	for PLUGIN in ${PLUGINS}; do
		load_plugin ${PLUGIN} plugin_post_vdr_start || return 1
	done
	return 0
}

