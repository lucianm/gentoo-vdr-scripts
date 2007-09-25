# $Id$

#
# Reading of shutdown-config-file and setting some default-values
#

shutdown_script_dir=/usr/share/vdr/shutdown
shutdown_data_dir=/var/vdr/shutdown-data

read_shutdown_config() {
	. /etc/conf.d/vdr.shutdown
	SHUTDOWN_ACTIVE="${SHUTDOWN_ACTIVE:-no}"
	WAKEUP_METHOD="${WAKEUP_METHOD:-acpi}"
	SHUTDOWN_FORCE_DETECT_INTERVALL="${SHUTDOWN_FORCE_DETECT_INTERVALL:-60}"
}

read_shutdown_config
