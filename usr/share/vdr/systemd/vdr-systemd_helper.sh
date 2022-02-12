#!/bin/sh

# VDR helper script for using a systemd unit together
# with media-tv/gentoo-vdr-scripts
#
# inspired by the old OpenRC script /etc/init.d/vdr by Mathias Schwarzott
# Lucian Muresan < lucianm AT users DOT sourceforge DOT net >
# Joerg Bornkessel <hd_brummy@gentoo.org>

# read our main options
. /etc/conf.d/vdr
. /etc/conf.d/vdr.watchdogd

# inspired by the old OpenRC script /etc/init.d/vdr:

# evaluate vdr-user's $HOME
vdr_user_home=$(eval echo ~vdr)
cd "${vdr_user_home}"
unset MAIL
. /usr/share/vdr/inc/functions.sh

include rc-functions
include plugin-functions
init_tmp_dirs

VDR_LOG_FILE="${PL_TMP}/vdr-start-log"

# this is the environment file to pass user and parameters to the systemd unit file
SYSTEMD_ENV_FILE="${PL_TMP}/systemd_env"

#common_init

# dummy functions to make the rest of gentoo-vdr-scripts happy,
# as we do not want to rely on openrc's implementations of these
# commands:
ebegin() {
	vdr_log "ACTION: $@"
}

eend() {
	vdr_log "RESULT: $@"
}

ewarn() {
	vdr_log "WARN:   $@"
}

einfo() {
	vdr_log "INFO:   $@"
}


# some additional logging functions
eerror() {
	vdr_log "ERROR:  $@"
}

eexitfail() {
	eerror "$@"
	exit 1
}


clear_logfile() {
	rm -f "${VDR_LOG_FILE}"
	printf "" > "${VDR_LOG_FILE}"
}

#
# Used to log error-messages in startscript to show them on
# OSD later when choosing apropriate point in commands.
#

vdr_log()
{
	echo "$@" >> "${VDR_LOG_FILE}"
}

#
#
# Depending on $1, we execute the scripts needed
# before/after starting, or before/after stopping VDR,
# and exit with non-zero error code on failure, in such
# way that the systemd unit will fail and the problems
# have to be investigated in logs, journal, or even
# by executing these parts of the script manually in
# the console as user 'vdr'
if [ "$1" = "--start-pre" ]; then
	ebegin "--start-pre"
	clear_logfile
	init_params
	init_plugin_loader start || eexitfail "init_plugin_loader start"
	load_addons_prefixed pre-start || eexitfail "load_addons_prefixed pre-start"

	# these options are what we need to start VDR from the systemd unit file
	echo "VDR_OPTS=\"${vdr_opts}\"" > ${SYSTEMD_ENV_FILE}

	# X11 DISPLAY
	# (needed for media-plugins/vdr-softhddevice supporting OpenGL OSD)
	echo "DISPLAY=$DISPLAY" >> ${SYSTEMD_ENV_FILE}

	# LANG LC_COLLATE from /etc/conf.d/vdr will be ignored, wrt bug 530690
	echo "LANG=$LANG" >> ${SYSTEMD_ENV_FILE}
	echo "LC_COLLATE=${VDR_SORT_ORDER}" >> ${SYSTEMD_ENV_FILE}
	# Using LC_ALL is strongly discouraged as it can't be overridden later on.
	# Please use it only when testing and never set it in a startup file.
#	echo "LC_ALL=$LANG" >> ${SYSTEMD_ENV_FILE}

	# remove the command line --user argument if set by the scripts so far,
	# as the user under which vdr will run is controlled by systemd
	sed -e "s:'-u' 'vdr' ::" -i ${SYSTEMD_ENV_FILE}

	sudo systemctl daemon-reload
	eend "--start-pre"
elif [ "$1" = "--start-post" ]; then
	ebegin "--start-post"
	load_addons_prefixed post-start || eexitfail "load_addons_prefixed post-start"
	eend "--start-post"
elif [ "$1" = "--stop-pre" ]; then
	ebegin "--stop-pre"
	init_plugin_loader stop || eexitfail "init_plugin_loader stop"
	load_addons_prefixed pre-stop || eexitfail "load_addons_prefixed pre-stop"
	eend "--stop-pre"
elif [ "$1" = "--stop-post" ]; then
	ebegin "--stop-post"
	load_addons_prefixed post-stop || eexitfail "load_addons_prefixed post-stop"
	eend "--stop-post"
fi
