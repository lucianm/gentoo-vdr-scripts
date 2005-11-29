addon_main() {
	for PLUGIN in ${PLUGINS}; do
		init_plugin_params ${PLUGIN}
		add_plugin_param "--plugin=${PLUGIN}"

		if ! load_plugin ${PLUGIN} plugin_pre_vdr_start; then
			ewarn "Plugin ${PLUGIN} not found, starting without it."
			continue
		fi

		add_param "${vdrplugin_opts[*]} ${_EXTRAOPTS}"
	done
}

