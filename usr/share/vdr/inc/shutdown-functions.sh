# $Id$

#
# Reading of shutdown-config-file and setting some default-values
#

shutdown_script_dir=/usr/share/vdr/shutdown
shutdown_data_dir=/var/vdr/shutdown-data

. /etc/conf.d/vdr.shutdown

# set defaults
SHUTDOWN_ACTIVE="${SHUTDOWN_ACTIVE:-no}"
SHUTDOWN_FORCE_DETECT_INTERVALL="${SHUTDOWN_FORCE_DETECT_INTERVALL:-60}"

