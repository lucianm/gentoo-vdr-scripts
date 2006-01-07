read_vdr_language() {
	local OSDLANG
	local LANG_TAB
	OSDLANG=$(awk -F= '/^OSDLanguage/ { print $2 }' /etc/vdr/setup.conf)
	LANG_TAB=("en" "de")
	VDR_LANGUAGE=${LANG_TAB[OSDLANG]}
}

