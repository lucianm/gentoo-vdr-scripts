check_dvbdevice() {
	[[ -e /dev/dvb/adapter0/frontend0 ]] && return 0
	condition_msg="dvb device not found"
	return 1
}

if [ "$DEVICE_CHECK" != "disabled" ]; then
	add_wait_condition check_dvbdevice
fi
