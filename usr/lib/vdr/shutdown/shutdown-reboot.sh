# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#   Various other contributors from gentoo.de
#

if [[ -z "${BOOT_MANAGER}" ]]; then
	error_mesg "Bootmanager not set, can not reboot."
	return
fi

unsupported_msg() {
	echo "Not supported up to now. Please contact zzam@gentoo.org or zzam at irc freenode."
}

case "${BOOT_MANAGER}" in
	grub)
		if [ -x /sbin/grub-set-default ]; 
		then 
			/bin/mount /boot 
			/sbin/grub-set-default ${REBOOT_ENTRY_GRUB}
		else
			unsupported_msg
			return
		fi 
		;;
	lilo)
		/sbin/lilo -R ${REBOOT_ENTRY_LILO}
		;;
	*)
		unsupported_msg
		return
		;;
esac

/sbin/shutdown -r now
