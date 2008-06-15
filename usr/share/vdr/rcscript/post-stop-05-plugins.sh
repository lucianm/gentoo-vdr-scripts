# $Id$

addon_main() {
	for PLUGIN in ${PLUGINS}; do
		load_plugin ${PLUGIN} plugin_post_vdr_stop || return 1
	done
	return 0
}

