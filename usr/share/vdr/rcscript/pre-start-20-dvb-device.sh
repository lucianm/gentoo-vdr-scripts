# $Id$
xdvb_device_notice_func() {
	ewarn "No DVB device found."
	ewarn "If you do not have DVB hardware, then set DEVICE_CHECK=no in /etc/conf.d/vdr"
}

check_dvbdevice() {
	[ -e /dev/dvb/adapter0/frontend0 ] && return 0
	condition_msg_func="dvb_device_notice_func"
	return 1
}

addon_main() {
	DEVICE_CHECK=${DEVICE_CHECK:-yes}

	if [ "${DEVICE_CHECK}" = "yes" ]; then
		add_wait_condition check_dvbdevice
	fi
	return 0
}

