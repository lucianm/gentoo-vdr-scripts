#
# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#   Various other contributors from gentoo.de
#

RTC_WAKEUP=/usr/sbin/rtc-wakeup.sh

if [ ! -x "${RTC_WAKEUP}" ]; then
	mesg "rtc-wakeup.sh not found"
	return 1
fi

if [ ! -e /sys/class/rtc/rtc0/wakealarm ]; then
	mesg "/sys/class/rtc/rtc0/wakealarm does not exist"
	return 1
fi

"${RTC_WAKEUP}" "${VDR_WAKEUP_TIME}"
