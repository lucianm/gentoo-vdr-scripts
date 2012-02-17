# $Id$
check_dvbdevice() {
	[ -e /dev/dvb/adapter0/frontend0 ] || return 1
	return 0
}

addon_main() {
	local ret
	if yesno "${DVB_DEVICE_WAIT:-${DEVICE_CHECK:-yes}}"; then
		ebegin "  Waiting for DVB devices"
		waitfor 10 check_dvbdevice
		eend "$?" "    No DVB device found."
		[ $? = 1 ] && eerror "    If you do not use DVB hardware, then disable DVB_DEVICE_WAIT in /etc/conf.d/vdr"
	fi
	return 0
}
