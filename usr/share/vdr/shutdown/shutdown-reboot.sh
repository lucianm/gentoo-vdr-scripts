# $Id$
# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#   Various other contributors from gentoo.de
#

if [ -z "${BOOT_MANAGER}" ]; then
	BOOT_MANAGER="auto"
fi

case "${BOOT_MANAGER}" in
	auto)
		if [ ! -L /etc/runlevels/boot/wakeup-reboot-halt ]; then
			rc-update add wakeup-reboot-halt boot
		fi

		/etc/init.d/wakeup-reboot-halt mark_for_reboot
		;;
	grub)
		mount /boot 
		if [ -n "${REBOOT_ENTRY_GRUB}" ]; then
			case "${GRUB_SET_REBOOT_ENTRY_METHOD:=grub-set-default}" in
				grub-set-default)
					if [ -x /sbin/grub-set-default ]; then
						/sbin/grub-set-default "${REBOOT_ENTRY_GRUB}"
					else
						mesg "command grub-set-default not found!"
					fi
					;;
				savedefault)
					if [ -x /sbin/grub ]; then
						echo "savedefault --default=${REBOOT_ENTRY_GRUB} --once" | /sbin/grub --batch
					else
						mesg "command grub-set-default not found!"
					fi
					;;
				*)
					mesg "Unknown grub method ${GRUB_SET_REBOOT_ENTRY_METHOD}."
					;;
			esac
		else
			mesg "reboot entry not set, can not reboot."
		fi
		;;
	lilo)
		mount /boot
		if [ -n "${REBOOT_ENTRY_LILO}" ]; then
			/sbin/lilo -R ${REBOOT_ENTRY_LILO}
		else
			mesg "reboot entry not set, can not reboot."
		fi
		;;
	*)
		mesg "Unsupported boot manager ${BOOT_MANAGER}"
		return
		;;
esac

/sbin/shutdown -r now
