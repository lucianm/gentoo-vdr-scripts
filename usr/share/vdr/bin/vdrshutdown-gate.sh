#!/bin/sh
# Author:
#   Matthias Schwarzott <zzam@gmx.de>
#   Various other contributors from gentoo.de
#
# You have to edit sudo-permissions to grant vdr permission to execute
# privileged commands. Start visudo and add a line like
#   vdr     ALL= NOPASSWD: /usr/share/vdr/bin/vdrshutdown-really.sh

. /usr/share/vdr/inc/functions.sh

include svdrpcmd
svdrp_command

#fork to background
if [ -z "${EXECUTED_BY_VDR_BG}" ]; then
	exec /usr/share/vdr/bin/vdr-bg.sh "$0" "$@"
	exit
fi

mesg() {
	"${SVDRPCMD}" MESG "$@"
}

sudo /usr/share/vdr/bin/vdrshutdown-really.sh "$@"

[ $? = 1 ] && mesg "sudo failed: call emerge --config gentoo-vdr-scripts"

exit 0
