#!/bin/bash
# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#   Various other contributors from gentoo.de
#

if [[ "$UID" != "0" ]]; then
	echo "This program should be run as root"
	exit 1
fi

# You have to edit sudo-permissions to grant vdr permission to execute
# privileged commands. Start visudo and add a line like
#   vdr     ALL= NOPASSWD: /usr/bin/nvram-wakeup, /sbin/shutdown
# Add /sbin/lilo, /sbin/grub-set-default, /bin/mount, /usr/sbin/vdrshutdown-acpi.sh as needed
SUDO=/usr/bin/sudo

VDRSHUTDOWN_ACPI=/usr/sbin/vdrshutdown-acpi.sh
[ -x /usr/bin/vdrshutdown-acpi.sh ] && VDRSHUTDOWN_ACPI=/usr/bin/vdrshutdown-acpi.sh

# get some config stuff from vdr.shutdown

NVRAM_CONFIG=$(grep -v "^#" /etc/conf.d/vdr.shutdown | grep NVRAM_CONFIG |cut -d "\"" -f 2)
USE_NVRAM=$(grep -v "^#" /etc/conf.d/vdr.shutdown | grep USE_NVRAM |cut -d "\"" -f 2)
USE_ACPI=$(grep -v "^#" /etc/conf.d/vdr.shutdown | grep USE_ACPI |cut -d "\"" -f 2)
BOOT_MANAGER=$(grep -v "^#" /etc/conf.d/vdr.shutdown | grep BOOT_MANAGER |cut -d "\"" -f 2)
REBOOT_ENTRY=$(grep -v "^#" /etc/conf.d/vdr.shutdown | grep REBOOT_ENTRY |cut -d "\"" -f 2)

# does the check script exits?
if [ -x ${CHECKSCRIPT} ]
then
	# run it
	msg=$(${CHECKSCRIPT} "$@") 
	test "x${msg}" != "x" && 
	{
		$SVDRPCMD MESG $msg &
		sleep 2
		exit 1;
	}	
fi

# set the hardware clock to the current system time
# ${SUDO} /sbin/hwclock --systohc

# is nvram-wakeup installed?
# does the config file exists?
if [ -x ${NVRAM_WAKEUP} ] && [ "${USE_NVRAM}" = "yes" ]
then

	if [ "x${NVRAM_CONFIG}" != "x" ]
	then
		# set time - use also nvram config file
		${SUDO} ${NVRAM_WAKEUP} --syslog -C ${NVRAM_CONFIG} -s $1
	else
		# set time
		${SUDO} ${NVRAM_WAKEUP} --syslog -s $1
	fi

	# analyse
	case $PIPESTATUS in
		0) 
		# all went ok - new date and time set
		${SUDO} /sbin/shutdown -h now
		EXITSTATUS=0
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
		# grub installed?
		if [ "${BOOT_MANAGER}" = "grub" ]
		then
			if [ -x /sbin/grub-set-default ]; 
			then 
				${SUDO} /bin/mount /boot 
				${SUDO} /sbin/grub-set-default ${REBOOT_ENTRY}
			else 
				echo "Not supported - upgrade grub to latest _unstable_ version and it should work"
			fi 
		else
			# i hope it is lilo
			${SUDO} /sbin/lilo -R PowerOff
		fi

		${SUDO} /sbin/shutdown -r now
		EXITSTATUS=1
		;;

		2) 
		# something went wrong
		# don't do anything - just exit with status 1
		EXITSTATUS=1

		echo "Something went wrong, please check your config files of nvram-wakeup"
		;;
	esac

	# exit with 0 if everything went ok.
	# exit with 1 if something went wrong.
	exit $EXITSTATUS

# is acpi in kernel activated?
elif [ -f /proc/acpi/alarm ] && [ "${USE_ACPI}" = "yes" ]
then
	${SUDO} ${VDRSHUTDOWN_ACPI} $1
	${SUDO} /sbin/shutdown -h now
else
	# normal poweroff
	${SUDO} /sbin/shutdown -h now
fi
