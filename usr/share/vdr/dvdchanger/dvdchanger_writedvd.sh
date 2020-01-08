#!/bin/bash
#
# 04 Mar 2006; Joerg Bornkessel <hd_brummy@gentoo.org>
# addaptded to gentoo-vdr-scripts

include svdrpcmd
svdrp_command

if [[ -z ${EXECUTED_BY_VDR_BG} ]]; then
	VDR_BG=/usr/share/vdr/bin/vdr-bg.sh
	[[ -e ${VDR_BG} ]] || VDR_BG="$(pkg-config --variable=libdir vdr)"/../vdr-bg.sh

	exec "${VDR_BG}" "${0}" "${@}"
	exit
fi

[[ -e /etc/conf.d/vdr.cd-dvd ]] && . /etc/conf.d/vdr.cd-dvd

ISO_FILE="${1// IMAGE/}"

#logger -t burnscript burn ${ISO_FILE} --

: ${VDR_DVDWRITER:=/dev/dvd}

[[ -e /etc/conf.d/vdr.dvdswitch ]] && . /etc/conf.d/vdr.dvdswitch


DVD_RECORDCMD="growisofs"
DVDPLUS_RECORD_OPTS="-use-the-force-luke=tty -dvd-compat"
if [[ -n ${VDR_DVDBURNSPEED} ]]; then
	DVDPLUS_RECORD_OPTS="${DVDPLUS_RECORD_OPTS} -speed=${VDR_DVDBURNSPEED}"
fi

unset SUDO_COMMAND

"${SVDRPCMD}" -d localhost MESG "DVD burn initiated"
"$DVD_RECORDCMD" $DVDPLUS_RECORD_OPTS -Z "$VDR_DVDWRITER"="${ISO_FILE}"
"${SVDRPCMD}" -d localhost MESG "DVD burn completed"
