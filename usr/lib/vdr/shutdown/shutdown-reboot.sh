# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#   Various other contributors from gentoo.de
#

# grub installed?
case "${BOOT_MANAGER}" in
	grub)
		if [ -x /sbin/grub-set-default ]; 
		then 
			/bin/mount /boot 
			/sbin/grub-set-default ${REBOOT_ENTRY_GRUB}
		else
			echo "Not supported up to now. Please contact zzam@gentoo.org or zzam at irc freenode"
		fi 
		;;
	lilo)
		/sbin/lilo -R ${REBOOT_ENTRY_LILO}
		;;
esac

/sbin/shutdown -r now
