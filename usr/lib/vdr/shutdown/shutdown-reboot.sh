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
			if [[ -n "${REBOOT_ENTRY_GRUB}" ]]; then
				GRUB_SET_REBOOT_ENTRY_METHOD="${GRUB_SET_REBOOT_ENTRY_METHOD:-grub-set-default}"
				case "${GRUB_SET_REBOOT_ENTRY_METHOD}" in
					grub-set-default)
						/sbin/grub-set-default ${REBOOT_ENTRY_GRUB}
						;;
					savedefault)
						echo "savedefault --default=${REBOOT_ENTRY_GRUB} --once" | /sbin/grub --batch
						;;
					*)
						error_mesg "Unknown grub method ${GRUB_SET_REBOOT_ENTRY_METHOD}."
						;;
				esac
			else
				error_mesg "reboot entry not set, can not reboot."
			fi
		else
			unsupported_msg
			return
		fi 
		;;
	lilo)
		if [[ -n "${REBOOT_ENTRY_LILO}" ]]; then
			/sbin/lilo -R ${REBOOT_ENTRY_LILO}
		else
			error_mesg "reboot entry not set, can not reboot."
		fi
		;;
	*)
		unsupported_msg
		return
		;;
esac

/sbin/shutdown -r now
