#!/bin/sh
# $Id: vdrshutdown-gate.sh 625 2008-07-06 12:59:34Z zzam $
# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#   Various other contributors from gentoo.de
#
# You have to edit sudo-permissions to grant vdr permission to execute
# privileged commands. Start visudo and add a line like
#   vdr     ALL= NOPASSWD: /usr/share/vdr/bin/vdrshutdown-really.sh

include svdrpcmd

#fork to background
if [ -z "${EXECUTED_BY_VDR_BG}" ]; then
	exec /usr/share/vdr/bin/vdr-bg.sh "$0" "$@"
	exit
fi

svdrp_command

mesg() {
	"${SVDRPCMD}" MESG "$@"
}

sudo /usr/share/vdr/bin/vdrshutdown-really.sh "$@"

[ $? = 1 ] && mesg "sudo failed: call emerge --config gentoo-vdr-scripts"

exit 0
