# $Id: wakeup-acpi.sh 571 2007-12-10 20:50:11Z zzam $
# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#   Various other contributors from gentoo.de
#

RTC_WAKEUP=/usr/sbin/rtc-wakeup.sh

wakeup_set() {
	if [ ! -x "${RTC_WAKEUP}" ]; then
		error_mesg "acpi-wakeup.sh not found"
		return 1
	fi

	if [ ! -e /sys/class/rtc/rtc0/wakealarm ]; then
		error_mesg "/sys/class/rtc/rtc0/wakealarm does not exist"
		return 1
	fi

	"${RTC_WAKEUP}" "$1"
}
