# $Id$
shutdown_script_dir=/usr/share/vdr/shutdown
shutdown_data_dir=/var/vdr/shutdown-data

read_shutdown_config() {
	source /etc/conf.d/vdr.shutdown
	SHUTDOWN_ACTIVE="${SHUTDOWN_ACTIVE:-no}"
	WAKEUP_METHOD="${WAKEUP_METHOD:-acpi}"
	SHUTDOWN_FORCE_DETECT_INTERVALL="${SHUTDOWN_FORCE_DETECT_INTERVALL:-60}"
}

read_shutdown_config

