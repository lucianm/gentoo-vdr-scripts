#!/bin/bash
# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#   Various other contributors from gentoo.de
#

if [[ "${UID}" != "0" ]]; then
	echo "This program should be run as root"
	exit 1
fi

VDR_WAKEUP_TIME="${1}"

ACPI_WAKEUP=/usr/sbin/acpi-wakeup.sh
NVRAM_WAKEUP=/usr/bin/nvram-wakeup

source /etc/conf.d/vdr.shutdown


wakeup_nvram() {
	if [[ ! -x ${NVRAM_WAKEUP} ]]; then
		echo error: no nvram
	fi

	CMD="${NVRAM_WAKEUP} --syslog"

	[[ -n "${NVRAM_CONFIG}" ]] && CMD="${CMD} -C ${NVRAM_CONFIG}"

	CMD="${CMD} -s ${VDR_WAKEUP_TIME}"

	${CMD}
	# analyse
	case $PIPESTATUS in
		0) 
		# all went ok
		EXITCODE=0
		;;
			
		1) 
		# all went ok - new date and time set.
		#
		# *** but we need to reboot. ***
		#
		# for some boards this is needed after every change.
		#
		# for some other boards, we only need this after changing the
		# status flag, i.e. from enabled to disabled or the other way.

		EXITCODE=0
		NEED_REBOOT=1
		;;

		2) 
		# something went wrong
		# don't do anything - just exit with status 1
		EXITCODE=1

		echo "Something went wrong, please check your config files of nvram-wakeup"
		;;
	esac
}

wakeup_acpi() {
	# is acpi in kernel activated?
	if [[ ! -f /proc/acpi/alarm ]]; then
		echo error: no acpi installed
	fi
	${ACPI_WAKEUP} ${VDR_WAKEUP_TIME}
}


NEED_REBOOT=0
EXITCODE=0
case "${WAKEUP_METHOD:-acpi}" in
	nvram)	wakeup_nvram ;;
	acpi)	wakeup_acpi ;;
esac

if [[ "${EXITCODE}" != "0" ]]; then
	exit ${EXITCODE}
fi

if [[ "${NEED_REBOOT}" == "1" ]]; then
	# grub installed?
	if [ "${BOOT_MANAGER}" = "grub" ]
	then
		if [ -x /sbin/grub-set-default ]; 
		then 
			/bin/mount /boot 
			/sbin/grub-set-default ${REBOOT_ENTRY}
		else 
			echo "Not supported - upgrade grub to latest _unstable_ version and it should work"
		fi 
	else
		# i hope it is lilo
		/sbin/lilo -R PowerOff
	fi

	/sbin/shutdown -r now
else
	:
	/sbin/shutdown -h now
fi
