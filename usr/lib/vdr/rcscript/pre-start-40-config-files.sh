# $Id$
source /usr/lib/vdr/inc/commands-functions.sh

addon_main() {
	ebegin "  config files"
	if [[ ! -d /var/vdr ]]; then
		mkdir -p /var/vdr/{shutdown-data,merged-config-files}
		chown vdr:vdr -R /var/vdr
		ewarn "    created /var/vdr"
	fi
	merge_commands_conf /etc/vdr/commands /etc/vdr/commands.conf "${ORDER_COMMANDS}"
	merge_commands_conf /etc/vdr/reccmds /etc/vdr/reccmds.conf "${ORDER_RECCMDS}"

	if [[ -f /etc/vdr/setup.conf ]]; then
		if [[ -n "${STARTUP_VOLUME}" ]]; then
			/bin/sed -i /etc/vdr/setup.conf -e "s/^CurrentVolume =.*\$/CurrentVolume = ${STARTUP_VOLUME}/"
		fi

		if [[ -n "${STARTUP_CHANNEL}" ]]; then
			/bin/sed -i /etc/vdr/setup.conf -e "s/^CurrentChannel =.*\$/CurrentChannel = ${STARTUP_CHANNEL}/"
		fi
	fi

	eend 0
	return 0
}
