#!/bin/bash
#
# $Header: /var/cvsroot/gentoo-x86/media-tv/vdr-dvd-scripts/files/0.0.3/dvdchanger_writedvd.sh,v 1.1 2007/07/21 22:40:13 hd_brummy Exp $
#
# 04 Mar 2006; Joerg Bornkessel <hd_brummy@gentoo.org>
# addaptded to gentoo-vdr-scripts

if [[ -z ${EXECUTED_BY_VDR_BG} ]]; then
	VDR_BG=/usr/share/vdr/bin/vdr-bg.sh
	[[ -e ${VDR_BG} ]] || VDR_BG=/usr/lib/vdr/bin/vdr-bg.sh

	exec "${VDR_BG}" "${0}" "${@}"
	exit
fi

[[ -e /etc/conf.d/vdr.cd-dvd ]] && source /etc/conf.d/vdr.cd-dvd

ISO_FILE="${1// IMAGE/}"

#logger -t burnscript burn ${ISO_FILE} --

: ${VDR_DVDWRITER:=/dev/dvd}

[[ -e /etc/conf.d/vdr.dvdswitch ]] && source /etc/conf.d/vdr.dvdswitch


DVD_RECORDCMD="growisofs"
DVDPLUS_RECORD_OPTS="-use-the-force-luke=tty -dvd-compat"
if [[ -n ${VDR_DVDBURNSPEED} ]]; then
	DVDPLUS_RECORD_OPTS="${DVDPLUS_RECORD_OPTS} -speed=${VDR_DVDBURNSPEED}"
fi

unset SUDO_COMMAND

svdrpsend.pl -d localhost "MESG DVD burn initiated"
"$DVD_RECORDCMD" $DVDPLUS_RECORD_OPTS -Z "$VDR_DVDWRITER"="${ISO_FILE}"
svdrpsend.pl -d localhost "MESG DVD burn completed"
