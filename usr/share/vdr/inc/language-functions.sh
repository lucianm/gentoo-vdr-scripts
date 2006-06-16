# $Id$
read_vdr_language() {
	local OSDLANG
	local LANG_TAB
	if [[ -f /etc/vdr/setup.conf ]]; then
		OSDLANG=$(awk -F= '/^OSDLanguage/ { print $2 }' /etc/vdr/setup.conf)
	else
		OSDLANG="0"
	fi
	LANG_TAB=("en" "de")
	VDR_LANGUAGE=${LANG_TAB[OSDLANG]}
}
