# $Id$

# Reads the language setting of vdr to localize the messages
# of start/shutdown-scripts
#
# At the moment only used for choosing localized commands.conf-files.

read_vdr_language() {
	local OSDLANG
	local LANG_TAB
	if [ -f /etc/vdr/setup.conf ]; then
		OSDLANG=$(awk -F= '/^OSDLanguage/ { print $2 }' /etc/vdr/setup.conf)
	else
		OSDLANG="0"
	fi
	case "$OSDLANG" in
	0) VDR_LANGUAGE="en" ;;
	1) VDR_LANGUAGE="de" ;;
	*) VDR_LANGUAGE="" ;;
	esac
}

