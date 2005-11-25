# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#   Various other contributors from gentoo.de
#

if [[ -z "${BOOT_MANAGER}" ]]; then
	error_mesg "Bootmanager not set, can not reboot."
	return
fi

case "${BOOT_MANAGER}" in
	grub)
		/bin/mount /boot 
		if [[ -n "${REBOOT_ENTRY_GRUB}" ]]; then
			case "${GRUB_SET_REBOOT_ENTRY_METHOD:=grub-set-default}" in
				grub-set-default)
					if [[ -x /sbin/grub-set-default ]]; then
						/sbin/grub-set-default "${REBOOT_ENTRY_GRUB}"
					else
						error_mesg "command grub-set-default not found!"
					fi
					;;
				savedefault)
					if [[ -x /sbin/grub ]]; then
						echo "savedefault --default=${REBOOT_ENTRY_GRUB} --once" | /sbin/grub --batch
					else
						error_mesg "command grub-set-default not found!"
					fi
					;;
				*)
					error_mesg "Unknown grub method ${GRUB_SET_REBOOT_ENTRY_METHOD}."
					;;
			esac
		else
			error_mesg "reboot entry not set, can not reboot."
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
		error_mesg "Unsupported boot manager ${BOOT_MANAGER}"
		return
		;;
esac

/sbin/shutdown -r now
